; ###########################################################
; ############### LENEX 3 VALIDATOR PB MODULE ###############
; ###########################################################

;   written by hgzh, 2024

;   This module provides a validator for LENEX 3 files using
;   the LENEX3Schema PureBasic module. Elements and their
;   attributes can be validated against the schema regarding
;   context, necessity and pattern matching.

; ###########################################################
;                          LICENSING
; Copyright (c) 2024 hgzh

; Permission is hereby granted, free of charge, to any person
; obtaining a copy of this software and associated
; documentation files (the "Software"), to deal in the
; Software without restriction, including without limitation
; the rights to use, copy, modify, merge, publish, distribute,
; sublicense, and/or sell copies of the Software, and to
; permit persons to whom the Software is furnished to do so,
; subject to the following conditions:

; The above copyright notice and this permission notice shall
; be included in all copies or substantial portions of the
; Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
; KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
; WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
; PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
; OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
; OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
; OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

; ###########################################################

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

Enumeration Issues
  ; ----------------------------------------
  ; public     :: validator issue codes
  ; ----------------------------------------
  #ATTRIBUTE_CONTEXT_MISMATCH
  #ATTRIBUTE_ENUMERATION_MISMATCH
  #ATTRIBUTE_PATTERN_MISMATCH
  #ATTRIBUTE_REQUIRED_MISSING
  #ELEMENT_COLLECT_MISMATCH
  #ELEMENT_COLLECT_NO_ELEMENT
  #ELEMENT_NOT_IN_SCHEMA
  #SUBELEMENT_CONTEXT_MISMATCH
  #SUBELEMENT_NOT_IN_SCHEMA
  #SUBELEMENT_REQUIRED_MISSING
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
Declare.i validateRequiredSubElements(*psValid.VALIDATOR, pzElement.s, List pllzSubElements.s(), pzPath.s)
Declare.i validateAttribute(*psValid.VALIDATOR, pzElement.s, pzAttribute.s, pzValue.s, pzPath.s)
Declare.i validateRequiredAttributes(*psValid.VALIDATOR, pzElement.s, List pllzAttributes.s(), pzPath.s)
Declare.s getAttributeDefault(*psValid.VALIDATOR, pzElement.s, pzAttribute.s)
Declare.i examineIssues()
Declare.i nextIssue()
Declare.i getIssueCode()
Declare.s getIssueSubject()

EndDeclareModule

Module LENEX3Validator

EnableExplicit

Global NewMap gmiTypeRegexp.i()

Structure ISSUE
  ; ----------------------------------------
  ; internal   :: validator issue
  ; ----------------------------------------
  iCode.i
  zSubject.s
EndStructure

Structure ISSUELIST
  ; ----------------------------------------
  ; internal   :: validator issue list
  ; ----------------------------------------
  List Issues.ISSUE()
EndStructure

Procedure.i issueHandler(piIGRF.i, piCode.i = -1, pzSubject.s = "")
; ----------------------------------------
; internal   :: validator issue handling
; param      :: piIGRF    -  issue handling mode
;                            0: insert new issue
;                            1: get issue list
;                            2: reset issue list
;                            3: free issue list
;               piCode    - (S: -1) issue code
;               pzSubject - (S: '') issue subject
; returns    :: (i) pointer to issue list if piIGR = 1, else 0
; ----------------------------------------
  Static *sList.ISSUELIST
; ----------------------------------------

  If piIGRF = 0
    ; //
    ; new issue
    ; //
    AddElement(*sList\Issues())
    *sList\Issues()\iCode    = piCode
    *sList\Issues()\zSubject = pzSubject
  ElseIf piIGRF = 1
    ; //
    ; get issue list
    ; //
    ProcedureReturn *sList
  ElseIf piIGRF = 2
    ; //
    ; reset issue list
    ; //
    FreeStructure(*sList)
    *sList = AllocateStructure(ISSUELIST)
  ElseIf piIGRF = 3
    ; //
    ; free issue list
    ; //
    FreeStructure(*sList)
  EndIf
  
  ProcedureReturn 0
  
EndProcedure

Procedure.i examineIssues()
; ----------------------------------------
; public     :: examine issues
; param      :: (none)
; returns    :: (i) #False - no issues in list
;                   #True - issues found
; ----------------------------------------
  Protected *sList.ISSUELIST
; ----------------------------------------

  *sList = issueHandler(1)
  ResetList(*sList\Issues())
  
  If ListSize(*sList\Issues()) > 0
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False

EndProcedure

Procedure.i nextIssue()
; ----------------------------------------
; public     :: set current issue to the next one
; param      :: (none)
; returns    :: (i) 1 - next issue available
;                   0 - no more issue
; ----------------------------------------
  Protected *sList.ISSUELIST
; ----------------------------------------

  *sList = issueHandler(1)
  
  ProcedureReturn NextElement(*sList\Issues())
  
EndProcedure

Procedure.i getIssueCode()
; ----------------------------------------
; public     :: get the code of the current issue
; param      :: (none)
; returns    :: (i) issue code
; ----------------------------------------
  Protected *sList.ISSUELIST
; ----------------------------------------

  *sList = issueHandler(1)
  
  If ListIndex(*sList\Issues())
    ProcedureReturn *sList\Issues()\iCode
  Else
    ProcedureReturn -1
  EndIf
  
EndProcedure

Procedure.s getIssueSubject()
; ----------------------------------------
; public     :: get the subject of the current issue
; param      :: (none)
; returns    :: (s) issue subject
; ----------------------------------------
  Protected *sList.ISSUELIST
; ----------------------------------------

  *sList = issueHandler(1)
  
  If ListIndex(*sList\Issues())
    ProcedureReturn *sList\Issues()\zSubject
  Else
    ProcedureReturn ""
  EndIf
  
EndProcedure

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
  
  ; //
  ; free issue list
  ; //
  issueHandler(3)

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
    issueHandler(0, #ELEMENT_COLLECT_NO_ELEMENT, pzSubElement)
    ProcedureReturn #INVALID
  EndIf
  
  ; //
  ; check element collect
  ; //
  If zCollect <> UCase(pzSubElement)
    issueHandler(0, #ELEMENT_COLLECT_MISMATCH, pzSubElement)
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
  ; reset issue list
  ; //
  issueHandler(2)

  ; //
  ; element
  ; //
  *Elem = LENEX3Schema::getElement(*psValid\Schema, pzElement)
  If *Elem = #Null
    issueHandler(0, #ELEMENT_NOT_IN_SCHEMA, pzElement)
    ProcedureReturn #INVALID
  EndIf

  ; //
  ; sub element existance
  ; //
  If LENEX3Schema::selectSubElement(*Elem, pzSubElement) = #INVALID
    issueHandler(0, #SUBELEMENT_NOT_IN_SCHEMA, pzSubElement)
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
    issueHandler(0, #SUBELEMENT_CONTEXT_MISMATCH, pzSubElement)
    ProcedureReturn #INVALID
  EndIf
  
  ProcedureReturn #VALID

EndProcedure

Procedure.i validateRequiredSubElements(*psValid.VALIDATOR, pzElement.s, List pllzSubElements.s(), pzPath.s)
; ----------------------------------------
; public     :: checks if given list contains all required sub elements
; param      :: *psValid          - validator structure
;               pzElement         - element name
;               pllzSubElements() - list with given sub elements
;               pzPath            - element path
; returns    :: (i) #INVALID - validation failed
;                   #VALID   - validation passed
; ----------------------------------------
  Protected.i iFound,
              iValid
  Protected.s zName
  Protected   *Elem,
              *Attr
; ----------------------------------------

  ; //
  ; reset issue list
  ; //
  issueHandler(2)

  ; //
  ; element
  ; //
  *Elem = LENEX3Schema::getElement(*psValid\Schema, pzElement)
  If *Elem = #Null
    issueHandler(0, #ELEMENT_NOT_IN_SCHEMA, pzElement)
    ProcedureReturn #INVALID
  EndIf
  
  ; //
  ; loop through all sub elements to check if they are required and existing in the list
  ; //
  iValid = #VALID
  LENEX3Schema::examineSubElements(*Elem)
  While LENEX3Schema::nextSubElement(*Elem)
    zName = LENEX3Schema::getSubElementName(*Elem)
    If LENEX3Schema::getSubElementRequired(*Elem) = #False Or validateSubElementContext(*Elem, zName, pzPath) = #INVALID
      Continue
    EndIf
    iFound = 0
    ForEach pllzSubElements()
      If UCase(pllzSubElements()) = zName
        iFound = 1
        Break
      EndIf
    Next
    If iFound = 0
      issueHandler(0, #SUBELEMENT_REQUIRED_MISSING, pllzSubElements())
      iValid = #INVALID
    EndIf
  Wend
  
  ProcedureReturn iValid
  
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
              zWorkValue,
              zName
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
  zName     = LENEX3Schema::getAttributeName(*pElement)
  
  ; //
  ; attribute value empty
  ; //
  If pzValue = ""
    If iRequired = #True And zDefault = ""
      issueHandler(0, #ATTRIBUTE_REQUIRED_MISSING, zName)
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
      issueHandler(0, #ATTRIBUTE_ENUMERATION_MISMATCH, zName)
      ProcedureReturn #INVALID
    EndIf
  Else
    If validateAttributeValuePattern(iType, zWorkValue) = #INVALID
      issueHandler(0, #ATTRIBUTE_PATTERN_MISMATCH, zName)
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
  ; reset issue list
  ; //
  issueHandler(2)
  
  ; //
  ; element
  ; //
  *Elem = LENEX3Schema::getElement(*psValid\Schema, pzElement)
  If *Elem = #Null
    issueHandler(0, #ELEMENT_NOT_IN_SCHEMA, pzElement)
    ProcedureReturn #INVALID
  EndIf
  
  ; //
  ; find attribute that matches context
  ; //
  *Attr = getAttributeInContext(*Elem, pzAttribute, pzPath)
  If *Attr = #Null
    issueHandler(0, #ATTRIBUTE_CONTEXT_MISMATCH, pzAttribute)
    ProcedureReturn #INVALID
  EndIf
  
  ; //
  ; validate attribute value
  ; //
  ProcedureReturn validateAttributeValue(*Elem, *Attr, pzValue)

EndProcedure

Procedure.i validateRequiredAttributes(*psValid.VALIDATOR, pzElement.s, List pllzAttributes.s(), pzPath.s)
; ----------------------------------------
; public     :: checks if given list contains all required attributes
; param      :: *psValid         - validator structure
;               pzElement        - element name
;               pllzAttributes() - list with given attributes
;               pzPath           - element path
; returns    :: (i) #INVALID - validation failed
;                   #VALID   - validation passed
; ----------------------------------------
  Protected.i iFound,
              iValid
  Protected   *Elem,
              *Attr
; ----------------------------------------

  ; //
  ; reset issue list
  ; //
  issueHandler(2)

  ; //
  ; element
  ; //
  *Elem = LENEX3Schema::getElement(*psValid\Schema, pzElement)
  If *Elem = #Null
    issueHandler(0, #ELEMENT_NOT_IN_SCHEMA, pzElement)
    ProcedureReturn #INVALID
  EndIf
  
  ; //
  ; loop through all attributes to check if they are required and existing in the list
  ; //
  iValid = #VALID
  LENEX3Schema::examineAttributes(*Elem)
  While LENEX3Schema::nextAttribute(*Elem)
    If LENEX3Schema::getAttributeRequired(*Elem) = #False Or validateContext(pzPath, LENEX3Schema::getAttributeContext(*Elem)) = #INVALID
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
      issueHandler(0, #ATTRIBUTE_REQUIRED_MISSING, pllzAttributes())
      iValid = #INVALID
    EndIf
  Wend
  
  ProcedureReturn iValid

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

EndModule