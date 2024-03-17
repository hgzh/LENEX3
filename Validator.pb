XIncludeFile "Schema.pb"

DeclareModule LENEX3Validator

;- >>> public constants declaration <<<

Enumeration Result
  ; ----------------------------------------
  ; public     :: validator results
  ; ----------------------------------------
  #INVALID
  #VALID
  #VALID_DEFAULT
EndEnumeration

;- >>> public structure declaration <<<

Structure VALIDATOR
  ; ----------------------------------------
  ; public     :: validator structure
  ; ----------------------------------------
  *Schema
EndStructure

;- >>> public function declaration <<<

Declare.i create()
Declare   free(*psValid.VALIDATOR)
Declare.i validateSubElement(*psValid.VALIDATOR, pzElement.s, pzSubElement.s, pzPath.s)
Declare.i validateAttribute(*psValid.VALIDATOR, pzElement.s, pzAttribute.s, pzValue.s, pzPath.s)
Declare.s getAttributeDefault(*psValid.VALIDATOR, pzElement.s, pzAttribute.s)
Declare.i validateRequiredAttributes(*psValid.VALIDATOR, pzElement.s, List pllzAttributes.s(), pzPath.s)

EndDeclareModule

Module LENEX3Validator

EnableExplicit

Global NewMap gmiTypeRegexp.i()

Procedure initTypeRegexp()
; ----------------------------------------
; internal   :: initialization of the type regular expressions
; param      :: (none)
; returns    :: (nothing)
; ----------------------------------------

  ClearMap(gmiTypeRegexp())
  
  gmiTypeRegexp(Str(LENEX3Schema::#ATTR_TYPE_CURRENCY))  = CreateRegularExpression(#PB_Any, "\d*")
  gmiTypeRegexp(Str(LENEX3Schema::#ATTR_TYPE_DATE))      = CreateRegularExpression(#PB_Any, "\d{4}\-\d{2}\-\d{2}")
  gmiTypeRegexp(Str(LENEX3Schema::#ATTR_TYPE_DAYTIME))   = CreateRegularExpression(#PB_Any, "\d{2}:\d{2}")
  gmiTypeRegexp(Str(LENEX3Schema::#ATTR_TYPE_NUMBER))    = CreateRegularExpression(#PB_Any, "[0-9\-]*")
  gmiTypeRegexp(Str(LENEX3Schema::#ATTR_TYPE_REACTTIME)) = CreateRegularExpression(#PB_Any, "[+-0]\d{1,}")
  gmiTypeRegexp(Str(LENEX3Schema::#ATTR_TYPE_STRING))    = CreateRegularExpression(#PB_Any, ".*", #PB_RegularExpression_DotAll | #PB_RegularExpression_AnyNewLine)
  gmiTypeRegexp(Str(LENEX3Schema::#ATTR_TYPE_STRINGINT)) = CreateRegularExpression(#PB_Any, "[\x20-\x7F]*")
  gmiTypeRegexp(Str(LENEX3Schema::#ATTR_TYPE_SWIMTIME))  = CreateRegularExpression(#PB_Any, "(NT|\d{2}:\d{2}:\d{2}.\d{2})")
  gmiTypeRegexp(Str(LENEX3Schema::#ATTR_TYPE_UID))       = CreateRegularExpression(#PB_Any, "[A-Za-z]\d+")
  
EndProcedure

Procedure freeTypeRegexp()
; ----------------------------------------
; internal   :: releases the type regular expressions
; param      :: (none)
; returns    :: (nothing)
; ----------------------------------------

  ForEach gmiTypeRegexp()
    FreeRegularExpression(gmiTypeRegexp())
  Next
  
  ClearMap(gmiTypeRegexp())

EndProcedure

Procedure.i create()
; ----------------------------------------
; public     :: create new lenex validator
; param      :: (none)
; returns    :: (i) pointer to validator structure
; ----------------------------------------
  Protected *sValid.VALIDATOR
; ----------------------------------------
  
  ; //
  ; create validator structure
  ; //
  *sValid = AllocateStructure(VALIDATOR)

  ; //
  ; create schema
  ; //
  *sValid\Schema = LENEX3Schema::init()
  
  ; //
  ; create type regexp
  ; //
  initTypeRegexp()
  
  ProcedureReturn *sValid

EndProcedure

Procedure free(*psValid.VALIDATOR)
; ----------------------------------------
; public     :: free validator structure
; param      :: *psValid - validator structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; free schema
  ; //
  LENEX3Schema::free(*psValid\Schema)
  
  ; //
  ; free validator structure
  ; //
  FreeStructure(*psValid)
  
  ; //
  ; free type regular expressions
  ; //
  freeTypeRegexp()

EndProcedure

Procedure.i validateContext(pzPath.s, pzContext.s)
; ----------------------------------------
; internal   :: checks if the context definition matches the given path
; param      :: pzPath    - element path
;               pzContext - context definition
; returns    :: (i) #INVALID - no match
;                   #VALID   - match
; ----------------------------------------
  Protected.i i,
              iCount,
              iFound
  Protected.s zPart
; ----------------------------------------
  
  ; //
  ; no context given, always valid
  ; //
  If pzContext = ""
    ProcedureReturn #VALID
  EndIf
  
  iCount = CountString(pzContext, "|")
  For i = 1 To iCount + 1
    zPart  = StringField(pzContext, i, "|")
    iFound = FindString(pzPath, "/" + RemoveString(zPart, "!"))
    If iFound > 0
      ProcedureReturn 1 - Bool(Left(zPart, 1) = "!")
    EndIf
  Next i

EndProcedure

Procedure.i validateSubElementContext(*pElement, pzSubElement.s, pzPath.s)
; ----------------------------------------
; internal   :: validates a sub element against the context definition
; param      :: *pElement    - element schema pointer
;               pzSubElement - sub element name
;               pzPath       - element path
; returns    :: (i) #INVALID - validation failed
;                   #VALID   - validation passed
; ----------------------------------------

  ProcedureReturn validateContext(pzPath + "/" + pzSubElement, LENEX3Schema::getSubElementContext(*pElement))

EndProcedure

Procedure.i validateSubElementCollect(*pElement, pzSubElement.s)
; ----------------------------------------
; internal   :: validates a sub element against it's collector
; param      :: *pElement    - element schema pointer
;               pzSubElement - sub element name
; returns    :: (i) #INVALID - validation failed
;                   #VALID   - validation passed
; ----------------------------------------
  Protected.s zCollect
  Protected   *Elem
; ----------------------------------------
  
  ; //
  ; no collect element specified
  ; //
  zCollect = LENEX3Schema::getElementCollect(*pElement)
  If zCollect = ""
    ProcedureReturn #INVALID
  EndIf
  
  ; //
  ; check element collect
  ; //
  If zCollect <> UCase(pzSubElement)
    ProcedureReturn #INVALID
  EndIf
  
  ProcedureReturn #VALID

EndProcedure

Procedure.i validateSubElement(*psValid.VALIDATOR, pzElement.s, pzSubElement.s, pzPath.s)
; ----------------------------------------
; public     :: validates a sub element
; param      :: *psValid     - validator structure
;               pzElement    - element name
;               pzSubElement - sub element name
;               pzPath       - element path
; returns    :: (i) #INVALID - validation failed
;                   #VALID   - validation passed
; ----------------------------------------
  Protected.i iType
  Protected   *Elem
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = LENEX3Schema::getElement(*psValid\Schema, pzElement)
  If *Elem = #Null
    ProcedureReturn #INVALID
  EndIf

  ; //
  ; sub element existance
  ; //
  If LENEX3Schema::selectSubElement(*Elem, pzSubElement) = #INVALID
    ProcedureReturn #INVALID
  EndIf
  
  ; //
  ; element type
  ; //
  iType = LENEX3Schema::getElementType(*Elem)
  
  ; //
  ; validate collect if necessary
  ; //
  If iType = LENEX3Schema::#ELEMENT_TYPE_COLLECT
    If validateSubElementCollect(*Elem, pzSubElement) = #INVALID
      ProcedureReturn #INVALID
    EndIf
  EndIf
  
  ; //
  ; validate context
  ; //
  If validateSubElementContext(*Elem, pzSubElement, pzPath) = #INVALID
    ProcedureReturn #INVALID
  EndIf
  
  ProcedureReturn #VALID

EndProcedure

Procedure.i validateAttributeValuePattern(piType.i, pzValue.s)
; ----------------------------------------
; internal   :: validates an attribute value against it's type pattern
; param      :: piType  - attribute type
;               pzValue - attribute value
; returns    :: (i) #INVALID - validation failed
;                   #VALID   - validation passed
; ----------------------------------------

  If MatchRegularExpression(gmiTypeRegexp(Str(piType)), pzValue) = 0
    ProcedureReturn #INVALID
  EndIf
  
  ProcedureReturn #VALID

EndProcedure

Procedure.i validateAttributeValueEnum(*pElement, pzValue.s)
; ----------------------------------------
; internal   :: validates an attribute value against it's enumeration values
; param      :: *pElement - schema element pointer
;               pzValue   - attribute value
; returns    :: (i) #INVALID - validation failed
;                   #VALID   - validation passed
; ----------------------------------------
  Protected.i iResult
; ----------------------------------------

  If LENEX3Schema::examineAttributeEnums(*pElement) <> 1
    ProcedureReturn #INVALID
  EndIf
  
  iResult = #INVALID
  While LENEX3Schema::nextAttributeEnum(*pElement)
    If LENEX3Schema::getAttributeEnumValue(*pElement) = pzValue
      iResult = #VALID
      Break
    EndIf
  Wend
  
  ProcedureReturn iResult

EndProcedure

Procedure.i validateAttributeValue(*pElement, *pAttribute, pzValue.s)
; ----------------------------------------
; internal   :: validates an attribute value against the schema definition
; param      :: *pElement   - element schema pointer
;               *pAttribute - attribute schema pointer
;               pzValue     - attribute value
; returns    :: (i) #INVALID       - validation failed
;                   #VALID         - validation passed with given value
;                   #VALID_DEFAULT - validation passed with default value
; ----------------------------------------
  Protected.i iType,
              iRequired
  Protected.s zDefault,
              zWorkValue
  Protected   *Attr
; ----------------------------------------
  
  ; //
  ; select attribute
  ; //
  LENEX3Schema::changeCurrentAttribute(*pElement, *pAttribute)
  
  ; //
  ; states
  ; //
  iType     = LENEX3Schema::getAttributeType(*pElement)
  iRequired = LENEX3Schema::getAttributeRequired(*pElement)
  zDefault  = LENEX3Schema::getAttributeDefault(*pElement)
  
  ; //
  ; attribute value empty
  ; //
  If pzValue = ""
    If iRequired = #True And zDefault = ""
      ProcedureReturn #INVALID
    ElseIf zDefault <> ""
      zWorkValue = zDefault
    Else
      ProcedureReturn #VALID
    EndIf
  Else
    zWorkValue = pzValue
  EndIf
  
  ; //
  ; attribute value matches type pattern or enumeration list
  ; //
  If iType = LENEX3Schema::#ATTR_TYPE_ENUMERATION
    If validateAttributeValueEnum(*pElement, zWorkValue) = #INVALID
      ProcedureReturn #INVALID
    EndIf
  Else
    If validateAttributeValuePattern(iType, zWorkValue) = #INVALID
      ProcedureReturn #INVALID
    EndIf
  EndIf
  
  ; //
  ; validation passed with given or default value
  ; //
  If zWorkValue = zDefault And pzValue = ""
    ProcedureReturn #VALID_DEFAULT
  Else
    ProcedureReturn #VALID
  EndIf
  
EndProcedure

Procedure.i getAttributeInContext(*pElement, pzAttribute.s, pzPath.s)
; ----------------------------------------
; internal   :: get an attribute of the element that matches the context definition
; param      :: *pElement   - element schema pointer
;               pzAttribute - attribute name
;               pzPath      - element path
; returns    :: (i) attribute schema pointer or #Null if no matching attribute
; ----------------------------------------
  Protected.s zContext
  Protected   *Attr
; ----------------------------------------
  
  ; //
  ; loop through existing attributes to find a matching one
  ; //
  LENEX3Schema::examineAttributes(*pElement)
  *Attr = LENEX3Schema::nextAttribute(*pElement)
  While *Attr
    zContext = LENEX3Schema::getAttributeContext(*pElement)
    If LENEX3Schema::getAttributeName(*pElement) = pzAttribute And (zContext = "" Or validateContext(pzPath, zContext) = 1)
      ProcedureReturn *Attr
    EndIf
    *Attr = LENEX3Schema::nextAttribute(*pElement)
  Wend
  
  ProcedureReturn #Null

EndProcedure

Procedure.i validateAttribute(*psValid.VALIDATOR, pzElement.s, pzAttribute.s, pzValue.s, pzPath.s)
; ----------------------------------------
; public     :: validates an attribute
; param      :: *psValid    - validator structure
;               pzElement   - element name
;               pzAttribute - attribute name
;               pzValue     - attribute value
;               pzPath      - element path
; returns    :: (i) #INVALID       - validation failed
;                   #VALID         - validation passed with given value
;                   #VALID_DEFAULT - validation passed with default value
; ----------------------------------------
  Protected *Elem,
            *Attr
; ----------------------------------------

  ; //
  ; element
  ; //
  *Elem = LENEX3Schema::getElement(*psValid\Schema, pzElement)
  If *Elem = #Null
    ProcedureReturn #INVALID
  EndIf
  
  ; //
  ; find attribute that matches context
  ; //
  *Attr = getAttributeInContext(*Elem, pzAttribute, pzPath)
  If *Attr = #Null
    ProcedureReturn #INVALID
  EndIf
  
  ; //
  ; validate attribute value
  ; //
  ProcedureReturn validateAttributeValue(*Elem, *Attr, pzValue)

EndProcedure

Procedure.s getAttributeDefault(*psValid.VALIDATOR, pzElement.s, pzAttribute.s)
; ----------------------------------------
; public     :: get the default value of the given attribute
; param      :: *psValid    - validator structure
;               pzElement   - element name
;               pzAttribute - attribute name
; returns    :: (s) attribute default value
; ----------------------------------------
  Protected *Elem,
            *Attr
; ----------------------------------------

  ; //
  ; element
  ; //
  *Elem = LENEX3Schema::getElement(*psValid\Schema, pzElement)
  If *Elem = #Null
    ProcedureReturn ""
  EndIf
  
  ; //
  ; attribute
  ; //
  If LENEX3Schema::selectAttribute(*Elem, pzAttribute) = 0
    ProcedureReturn ""
  EndIf
  
  ; //
  ; attribute default value
  ; //
  ProcedureReturn LENEX3Schema::getAttributeDefault(*Elem)

EndProcedure

Procedure.i validateRequiredAttributes(*psValid.VALIDATOR, pzElement.s, List pllzAttributes.s(), pzPath.s)
; ----------------------------------------
; public     :: checks if given list contains all required attributes
; param      :: *psValid        - validator structure
;               pzElement       - element name
;               pllAttributes() - list with given attributes
;               pzPath          - element path
; returns    :: (i) #INVALID       - validation failed
;                   #VALID         - validation passed
; ----------------------------------------
  Protected.i iFound
  Protected   *Elem,
              *Attr
; ----------------------------------------

  ; //
  ; element
  ; //
  *Elem = LENEX3Schema::getElement(*psValid\Schema, pzElement)
  If *Elem = #Null
    ProcedureReturn #INVALID
  EndIf
  
  ; //
  ; loop through all attributes to check if they are required and existing in the list
  ; //
  LENEX3Schema::examineAttributes(*Elem)
  While LENEX3Schema::nextAttribute(*Elem)
    If LENEX3Schema::getAttributeRequired(*Elem) = #False Or validateContext(pzPath, LENEX3Schema::getAttributeContext(*Elem)) = #False
      Continue
    EndIf
    iFound = 0
    ForEach pllzAttributes()
      If LCase(pllzAttributes()) = LENEX3Schema::getAttributeName(*Elem)
        iFound = 1
        Break
      EndIf
    Next
    If iFound = 0
      ProcedureReturn #INVALID
    EndIf
  Wend
  
  ProcedureReturn #VALID

EndProcedure

EndModule