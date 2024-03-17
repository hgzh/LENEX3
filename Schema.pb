; ###########################################################
; ################ LENEX 3 SCHEMA PB MODULE #################
; ###########################################################

;   written by hgzh, 2024

;   This module provides an interface to the LENEX 3 file
;   schema as of 2023-03-03, available on swimrankings.net.
;   The schema definition has to be received and initialized
;   by calling getSchema() at first. Afterwards, the schema
;   can be accessed using the public element, sub element and
;   attribute functions.

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

DeclareModule LENEX3Schema

;- >>> public structure declaration <<<

Enumeration SchemaAttributeType
  ; ----------------------------------------
  ; public     :: schema attribute types
  ; ----------------------------------------
  #ATTR_TYPE_STRING
  #ATTR_TYPE_STRINGINT
  #ATTR_TYPE_NUMBER
  #ATTR_TYPE_ENUMERATION
  #ATTR_TYPE_DATE
  #ATTR_TYPE_DAYTIME
  #ATTR_TYPE_CURRENCY
  #ATTR_TYPE_SWIMTIME
  #ATTR_TYPE_REACTTIME
  #ATTR_TYPE_UID
EndEnumeration

Enumeration SchemaElementType
  ; ----------------------------------------
  ; public     :: schema element types
  ; ----------------------------------------
  #ELEMENT_TYPE_OBJECT
  #ELEMENT_TYPE_COLLECT
EndEnumeration

Structure ATTRIBUTE
  ; ----------------------------------------
  ; public     :: single attribute of element
  ; ----------------------------------------
  zName.s       ; name of attribute
  iType.i       ; attribute type
  iRequired.i   ; #True if attribute is required
  zDefault.s    ; default value
  zContext.s    ; context in which the attribute is used
  List Enum.s() ; list of accetable values for enumerations
EndStructure

Structure SUBELEMENT
  ; ----------------------------------------
  ; public     :: sub element reference
  ; ----------------------------------------
  zName.s     ; name of subelement
  iRequired.i ; #True if attribute is required
  zContext.s  ; context in which the sub element is used
EndStructure

Structure ELEMENT
  ; ----------------------------------------
  ; public     :: single element
  ; ----------------------------------------
  zName.s                ; name of the element
  iType.i                ; element type
  zCollect.s             ; name of the sub element that is collected
  List Attr.ATTRIBUTE()  ; list of attributes
  List Elem.SUBELEMENT() ; list of sub elements referred to by name
EndStructure

Structure V3
  ; ----------------------------------------
  ; public     :: base structure of LENEX3 schema
  ; ----------------------------------------
  List Elem.ELEMENT()  ; list of LENEX3 elements
EndStructure

;- >>> public function declaration <<<

Declare.i getSchema()
Declare.i getElement(*psSchema.V3, pzName.s)
Declare.i getElementType(*psElement.ELEMENT)
Declare.s getElementCollect(*psElement.ELEMENT)
Declare   examineSubElements(*psElement.ELEMENT)
Declare.i nextSubElement(*psElement.ELEMENT)
Declare.s getSubElementName(*psElement.ELEMENT)
Declare.s getSubElementContext(*psElement.ELEMENT)
Declare.i getSubElementRequired(*psElement.ELEMENT)
Declare   examineAttributes(*psElement.ELEMENT)
Declare.i nextAttribute(*psElement.ELEMENT)
Declare.i selectAttribute(*psElement.ELEMENT, pzName.s)
Declare.i getAttributeType(*psElement.ELEMENT)
Declare.s getAttributeName(*psElement.ELEMENT)
Declare.s getAttributeContext(*psElement.ELEMENT)
Declare.s getAttributeDefault(*psElement.ELEMENT)
Declare.i getAttributeRequired(*psElement.ELEMENT)
Declare.i examineAttributeEnums(*psElement.ELEMENT)
Declare.i nextAttributeEnum(*psElement.ELEMENT)
Declare.s getAttributeEnumValue(*psElement.ELEMENT)

EndDeclareModule

Module LENEX3Schema

EnableExplicit

;- >>> internal handling functions <<<

Procedure defineElement(*psS.V3, pzName.s, piType.i, pzCollect.s = "")
; ----------------------------------------
; internal   :: start definition of a new element
; param      :: *psS      - schema structure
;               pzName    - element name
;               piType    - element type
;               pzCollect - (S: '') name of collected element
; returns    :: (i) pointer to new element
; ----------------------------------------

  AddElement(*psS\Elem())
  With *psS\Elem()
    \zName    = pzName
    \iType    = piType
    \zCollect = pzCollect
  EndWith
  
  ProcedureReturn @*psS\Elem()

EndProcedure

Procedure addSubElement(*psE.ELEMENT, pzName.s, piRequired.i = #False, pzContext.s = "")
; ----------------------------------------
; internal   :: add a sub element to the element list
; param      :: *psE       - element pointer
;               pzName     - element name
;               piRequired - (S: #False) #True  : required
;                                        #False : not required
;               pzContext  - (S: '') element context
; returns    :: (nothing)
; ----------------------------------------

  AddElement(*psE\Elem())
  *psE\Elem()\zName     = pzName
  *psE\Elem()\iRequired = piRequired
  *psE\Elem()\zContext  = pzContext

EndProcedure

Procedure addAttribute(*psE.ELEMENT, pzName.s, piType.i, piRequired.i = #False, pzDefault.s = "", pzContext.s = "")
; ----------------------------------------
; internal   :: start definition of a new attribute
; param      :: *psE       - element pointer
;               pzName     - attribute name
;               piType     - attribute type
;               piRequired - (S: #False) #True  : required
;                                        #False : not required
;               pzDefault  - (S: '') default value for attribute
;               pzContext  - (S: '') attribute context
; returns    :: (i) pointer to new attribute
; ----------------------------------------
  
  AddElement(*psE\Attr())
  With *psE\Attr()
    \zName     = pzName
    \iType     = piType
    \iRequired = piRequired
    \zDefault  = pzDefault
    \zContext  = pzContext
  EndWith
  
  ProcedureReturn @*psE\Attr()

EndProcedure

Procedure addEnumValue(*psA.ATTRIBUTE, pzValue.s)
; ----------------------------------------
; internal   :: add a enum value to the attribute
; param      :: *psA       - attribute pointer
;               pzValue    - enum value
; returns    :: (nothing)
; ----------------------------------------

  AddElement(*psA\Enum())
  *psA\Enum() = pzValue

EndProcedure

Procedure addEnumCourseCodes(*psA.ATTRIBUTE)
; ----------------------------------------
; internal   :: add course codes to the attribute
; param      :: *psA       - attribute pointer
; returns    :: (nothing)
; ----------------------------------------

  addEnumValue(*psA, "LCM")
  addEnumValue(*psA, "SCM")
  addEnumValue(*psA, "SCY")
  addEnumValue(*psA, "SCM16")
  addEnumValue(*psA, "SCM20")
  addEnumValue(*psA, "SCM33")
  addEnumValue(*psA, "SCY20")
  addEnumValue(*psA, "SCY27")
  addEnumValue(*psA, "SCY33")
  addEnumValue(*psA, "SCY36")
  addEnumValue(*psA, "OPEN")

EndProcedure

Procedure addEnumCurrencyCodes(*psA.ATTRIBUTE)
; ----------------------------------------
; internal   :: add currency codes to the attribute
; param      :: *psA       - attribute pointer
; returns    :: (nothing)
; ----------------------------------------

  addEnumValue(*psA, "AUD")
  addEnumValue(*psA, "BRL")
  addEnumValue(*psA, "CAD")
  addEnumValue(*psA, "CHF")
  addEnumValue(*psA, "DKK")
  addEnumValue(*psA, "DZD")
  addEnumValue(*psA, "GBP")
  addEnumValue(*psA, "DR")
  addEnumValue(*psA, "EUR")
  addEnumValue(*psA, "HRK")
  addEnumValue(*psA, "INR")
  addEnumValue(*psA, "IQD")
  addEnumValue(*psA, "IRR")
  addEnumValue(*psA, "JPY")
  addEnumValue(*psA, "KRW")
  addEnumValue(*psA, "KWD")
  addEnumValue(*psA, "MXP")
  addEnumValue(*psA, "NGN")
  addEnumValue(*psA, "NOK")
  addEnumValue(*psA, "NZD")
  addEnumValue(*psA, "PHP")
  addEnumValue(*psA, "PKR")
  addEnumValue(*psA, "PYG")
  addEnumValue(*psA, "RUR")
  addEnumValue(*psA, "SAR")
  addEnumValue(*psA, "SEK")
  addEnumValue(*psA, "TND")
  addEnumValue(*psA, "USD")
  
EndProcedure

Procedure addEnumNationCodes(*psA.ATTRIBUTE)
; ----------------------------------------
; internal   :: add nation codes to the attribute
; param      :: *psA       - attribute pointer
; returns    :: (nothing)
; ----------------------------------------

  addEnumValue(*psA, "AFG")
  addEnumValue(*psA, "ALB")
  addEnumValue(*psA, "ALG")
  addEnumValue(*psA, "ASA")
  addEnumValue(*psA, "AND")
  addEnumValue(*psA, "ANG")
  addEnumValue(*psA, "ANT")
  addEnumValue(*psA, "ARG")
  addEnumValue(*psA, "ARM")
  addEnumValue(*psA, "ARU")
  addEnumValue(*psA, "AUS")
  addEnumValue(*psA, "AUT")
  addEnumValue(*psA, "AZE")
  addEnumValue(*psA, "BAH")
  addEnumValue(*psA, "BRN")
  addEnumValue(*psA, "BAN")
  addEnumValue(*psA, "BAR")
  addEnumValue(*psA, "BLR")
  addEnumValue(*psA, "BEL")
  addEnumValue(*psA, "BIZ")
  addEnumValue(*psA, "BEN")
  addEnumValue(*psA, "BER")
  addEnumValue(*psA, "BHU")
  addEnumValue(*psA, "BOL")
  addEnumValue(*psA, "BIH")
  addEnumValue(*psA, "BOT")
  addEnumValue(*psA, "BRA")
  addEnumValue(*psA, "IVB")
  addEnumValue(*psA, "BRU")
  addEnumValue(*psA, "BUL")
  addEnumValue(*psA, "BUR")
  addEnumValue(*psA, "BDI")
  addEnumValue(*psA, "CAM")
  addEnumValue(*psA, "CMR")
  addEnumValue(*psA, "CAN")
  addEnumValue(*psA, "CPV")
  addEnumValue(*psA, "CAY")
  addEnumValue(*psA, "CAF")
  addEnumValue(*psA, "CHA")
  addEnumValue(*psA, "CHI")
  addEnumValue(*psA, "CHN")
  addEnumValue(*psA, "TPE")
  addEnumValue(*psA, "COL")
  addEnumValue(*psA, "COM")
  addEnumValue(*psA, "CGO")
  addEnumValue(*psA, "COK")
  addEnumValue(*psA, "CRC")
  addEnumValue(*psA, "CRO")
  addEnumValue(*psA, "CUB")
  addEnumValue(*psA, "CYP")
  addEnumValue(*psA, "CZE")
  addEnumValue(*psA, "PRK")
  addEnumValue(*psA, "COD")
  addEnumValue(*psA, "DEN")
  addEnumValue(*psA, "DJI")
  addEnumValue(*psA, "DMA")
  addEnumValue(*psA, "DOM")
  addEnumValue(*psA, "ECU")
  addEnumValue(*psA, "EGY")
  addEnumValue(*psA, "ESA")
  addEnumValue(*psA, "GEQ")
  addEnumValue(*psA, "ERI")
  addEnumValue(*psA, "EST")
  addEnumValue(*psA, "ETH")
  addEnumValue(*psA, "FRO")
  addEnumValue(*psA, "FIJ")
  addEnumValue(*psA, "FIN")
  addEnumValue(*psA, "MKD")
  addEnumValue(*psA, "FRA")
  addEnumValue(*psA, "GAB")
  addEnumValue(*psA, "GAM")
  addEnumValue(*psA, "GEO")
  addEnumValue(*psA, "GER")
  addEnumValue(*psA, "GHA")
  addEnumValue(*psA, "GIB")
  addEnumValue(*psA, "GBR")
  addEnumValue(*psA, "GRE")
  addEnumValue(*psA, "GRN")
  addEnumValue(*psA, "GUM")
  addEnumValue(*psA, "GUA")
  addEnumValue(*psA, "GUI")
  addEnumValue(*psA, "GBS")
  addEnumValue(*psA, "GUY")
  addEnumValue(*psA, "HAI")
  addEnumValue(*psA, "HON")
  addEnumValue(*psA, "HKG")
  addEnumValue(*psA, "HUN")
  addEnumValue(*psA, "IRI")
  addEnumValue(*psA, "ISL")
  addEnumValue(*psA, "IND")
  addEnumValue(*psA, "INA")
  addEnumValue(*psA, "IRQ")
  addEnumValue(*psA, "IRL")
  addEnumValue(*psA, "ISR")
  addEnumValue(*psA, "ITA")
  addEnumValue(*psA, "CIV")
  addEnumValue(*psA, "JAM")
  addEnumValue(*psA, "JPN")
  addEnumValue(*psA, "JOR")
  addEnumValue(*psA, "KAZ")
  addEnumValue(*psA, "KEN")
  addEnumValue(*psA, "KIR")
  addEnumValue(*psA, "KOR")
  addEnumValue(*psA, "KUW")
  addEnumValue(*psA, "KGZ")
  addEnumValue(*psA, "LAO")
  addEnumValue(*psA, "LAT")
  addEnumValue(*psA, "LBN")
  addEnumValue(*psA, "LES")
  addEnumValue(*psA, "LBR")
  addEnumValue(*psA, "LBA")
  addEnumValue(*psA, "LIE")
  addEnumValue(*psA, "LTU")
  addEnumValue(*psA, "LUX")
  addEnumValue(*psA, "MAC")
  addEnumValue(*psA, "MAD")
  addEnumValue(*psA, "MAW")
  addEnumValue(*psA, "MAS")
  addEnumValue(*psA, "MDV")
  addEnumValue(*psA, "MLI")
  addEnumValue(*psA, "MLT")
  addEnumValue(*psA, "MHL")
  addEnumValue(*psA, "MTN")
  addEnumValue(*psA, "MRI")
  addEnumValue(*psA, "MEX")
  addEnumValue(*psA, "FSM")
  addEnumValue(*psA, "MDA")
  addEnumValue(*psA, "MON")
  addEnumValue(*psA, "MNE")
  addEnumValue(*psA, "MGL")
  addEnumValue(*psA, "MAR")
  addEnumValue(*psA, "MOZ")
  addEnumValue(*psA, "MYA")
  addEnumValue(*psA, "NAM")
  addEnumValue(*psA, "NRU")
  addEnumValue(*psA, "NEP")
  addEnumValue(*psA, "NED")
  addEnumValue(*psA, "AHO")
  addEnumValue(*psA, "NZL")
  addEnumValue(*psA, "NCA")
  addEnumValue(*psA, "NIG")
  addEnumValue(*psA, "NGR")
  addEnumValue(*psA, "NMA")
  addEnumValue(*psA, "NOR")
  addEnumValue(*psA, "OMA")
  addEnumValue(*psA, "PAK")
  addEnumValue(*psA, "PLW")
  addEnumValue(*psA, "PLE")
  addEnumValue(*psA, "PAN")
  addEnumValue(*psA, "PNG")
  addEnumValue(*psA, "PAR")
  addEnumValue(*psA, "PER")
  addEnumValue(*psA, "PHI")
  addEnumValue(*psA, "POL")
  addEnumValue(*psA, "POR")
  addEnumValue(*psA, "PUR")
  addEnumValue(*psA, "QAT")
  addEnumValue(*psA, "ROU")
  addEnumValue(*psA, "RUS")
  addEnumValue(*psA, "RWA")
  addEnumValue(*psA, "STP")
  addEnumValue(*psA, "LCA")
  addEnumValue(*psA, "SAM")
  addEnumValue(*psA, "SMR")
  addEnumValue(*psA, "KSA")
  addEnumValue(*psA, "SEN")
  addEnumValue(*psA, "SRB")
  addEnumValue(*psA, "SEY")
  addEnumValue(*psA, "SLE")
  addEnumValue(*psA, "SGP")
  addEnumValue(*psA, "SVK")
  addEnumValue(*psA, "SLO")
  addEnumValue(*psA, "SOL")
  addEnumValue(*psA, "SOM")
  addEnumValue(*psA, "RSA")
  addEnumValue(*psA, "ESP")
  addEnumValue(*psA, "SRI")
  addEnumValue(*psA, "SKN")
  addEnumValue(*psA, "VIN")
  addEnumValue(*psA, "SUD")
  addEnumValue(*psA, "SUR")
  addEnumValue(*psA, "SWZ")
  addEnumValue(*psA, "SWE")
  addEnumValue(*psA, "SUI")
  addEnumValue(*psA, "SYR")
  addEnumValue(*psA, "TAH")
  addEnumValue(*psA, "TJK")
  addEnumValue(*psA, "TAN")
  addEnumValue(*psA, "THA")
  addEnumValue(*psA, "TLS")
  addEnumValue(*psA, "TOG")
  addEnumValue(*psA, "TGA")
  addEnumValue(*psA, "TRI")
  addEnumValue(*psA, "TUN")
  addEnumValue(*psA, "TUR")
  addEnumValue(*psA, "TKM")
  addEnumValue(*psA, "TUV")
  addEnumValue(*psA, "UGA")
  addEnumValue(*psA, "UKR")
  addEnumValue(*psA, "UAE")
  addEnumValue(*psA, "USA")
  addEnumValue(*psA, "URU")
  addEnumValue(*psA, "UZB")
  addEnumValue(*psA, "VAN")
  addEnumValue(*psA, "VEN")
  addEnumValue(*psA, "VIE")
  addEnumValue(*psA, "ISV")
  addEnumValue(*psA, "YEM")
  addEnumValue(*psA, "ZAM")
  addEnumValue(*psA, "ZIM")

EndProcedure

Procedure addEnumTimingCodes(*psA.ATTRIBUTE)
; ----------------------------------------
; internal   :: add timing codes to the attribute
; param      :: *psA       - attribute pointer
; returns    :: (nothing)
; ----------------------------------------

  addEnumValue(*psA, "AUTOMATIC")
  addEnumValue(*psA, "SEMIAUTOMATIC")
  addEnumValue(*psA, "MANUAL3")
  addEnumValue(*psA, "MANUAL2")
  addEnumValue(*psA, "MANUAL1")

EndProcedure

;- >>> internal initialization functions <<<

Procedure initAgedate(*psS.V3)
; ----------------------------------------
; internal   :: initialize AGEDATE element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "AGEDATE", #ELEMENT_TYPE_OBJECT)
  
  ; //
  ; type
  ; //
  *Attr = addAttribute(*Elem, "type", #ATTR_TYPE_ENUMERATION, #True)
  addEnumValue(*Attr, "YEAR")
  addEnumValue(*Attr, "DATE")
  addEnumValue(*Attr, "POR")
  addEnumValue(*Attr, "CAN.FNQ")
  addEnumValue(*Attr, "LUX")
  
  ; //
  ; value
  ; //
  addAttribute(*Elem, "value", #ATTR_TYPE_DATE, #True)

EndProcedure

Procedure initAgegroup(*psS.V3)
; ----------------------------------------
; internal   :: initialize AGEGROUP element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "AGEGROUP", #ELEMENT_TYPE_OBJECT)
  
  ; //
  ; agegroupid
  ; //
  *Attr = addAttribute(*Elem, "agegroupid", #ATTR_TYPE_NUMBER, #True, "", "EVENT")

  ; //
  ; agemax
  ; //
  *Attr = addAttribute(*Elem, "agemax", #ATTR_TYPE_NUMBER, #True)

  ; //
  ; agemin
  ; //
  *Attr = addAttribute(*Elem, "agemin", #ATTR_TYPE_NUMBER, #True)
  
  ; //
  ; gender
  ; //
  *Attr = addAttribute(*Elem, "gender", #ATTR_TYPE_ENUMERATION, #False, "", "EVENT")
  addEnumValue(*Attr, "M")
  addEnumValue(*Attr, "F")
  addEnumValue(*Attr, "X")

  ; //
  ; calculate
  ; //
  *Attr = addAttribute(*Elem, "calculate", #ATTR_TYPE_ENUMERATION)
  addEnumValue(*Attr, "SINGLE")
  addEnumValue(*Attr, "TOTAL")

  ; //
  ; handicap
  ; //
  *Attr = addAttribute(*Elem, "handicap", #ATTR_TYPE_ENUMERATION)
  addEnumValue(*Attr, "0")
  addEnumValue(*Attr, "1")
  addEnumValue(*Attr, "2")
  addEnumValue(*Attr, "3")
  addEnumValue(*Attr, "4")
  addEnumValue(*Attr, "5")
  addEnumValue(*Attr, "6")
  addEnumValue(*Attr, "7")
  addEnumValue(*Attr, "8")
  addEnumValue(*Attr, "9")
  addEnumValue(*Attr, "10")
  addEnumValue(*Attr, "11")
  addEnumValue(*Attr, "12")
  addEnumValue(*Attr, "13")
  addEnumValue(*Attr, "14")
  addEnumValue(*Attr, "15")
  addEnumValue(*Attr, "20")
  addEnumValue(*Attr, "34")
  addEnumValue(*Attr, "49")
  
  ; //
  ; levelmax
  ; //
  *Attr = addAttribute(*Elem, "levelmax", #ATTR_TYPE_STRING)

  ; //
  ; levelmin
  ; //
  *Attr = addAttribute(*Elem, "levelmin", #ATTR_TYPE_STRING)

  ; //
  ; levels
  ; //
  *Attr = addAttribute(*Elem, "levels", #ATTR_TYPE_STRING)
  
  ; //
  ; name
  ; //
  *Attr = addAttribute(*Elem, "name", #ATTR_TYPE_STRING)
  
  ; //
  ; subelements
  ; //
  addSubElement(*Elem, "RANKINGS")
  
EndProcedure

Procedure initAgegroups(*psS.V3)
; ----------------------------------------
; internal   :: initialize AGEGROUPS element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "AGEGROUPS", #ELEMENT_TYPE_COLLECT, "AGEGROUP")
  
EndProcedure

Procedure initAthlete(*psS.V3)
; ----------------------------------------
; internal   :: initialize ATHLETE element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "ATHLETE", #ELEMENT_TYPE_OBJECT)

  ; //
  ; athleteid
  ; //
  *Attr = addAttribute(*Elem, "athleteid", #ATTR_TYPE_NUMBER, #True, "", "MEET")

  ; //
  ; birthdate
  ; //
  *Attr = addAttribute(*Elem, "birthdate", #ATTR_TYPE_DATE, #True)

  ; //
  ; firstname
  ; //
  *Attr = addAttribute(*Elem, "firstname", #ATTR_TYPE_STRING, #True)
  
  ; //
  ; firstname.en
  ; //
  *Attr = addAttribute(*Elem, "firstname.en", #ATTR_TYPE_STRINGINT)

  ; //
  ; gender
  ; //
  *Attr = addAttribute(*Elem, "gender", #ATTR_TYPE_ENUMERATION, #True)
  addEnumValue(*Attr, "M")
  addEnumValue(*Attr, "F")

  ; //
  ; lastname
  ; //
  *Attr = addAttribute(*Elem, "lastname", #ATTR_TYPE_STRING, #True)
  
  ; //
  ; lastname.en
  ; //
  *Attr = addAttribute(*Elem, "lastname.en", #ATTR_TYPE_STRINGINT)

  ; //
  ; level
  ; //
  *Attr = addAttribute(*Elem, "level", #ATTR_TYPE_STRING)
  
  ; //
  ; license
  ; //
  *Attr = addAttribute(*Elem, "license", #ATTR_TYPE_STRING, #False, "", "MEET")

  ; //
  ; nameprefix
  ; //
  *Attr = addAttribute(*Elem, "nameprefix", #ATTR_TYPE_STRING)
  
  ; //
  ; nation
  ; //
  *Attr = addAttribute(*Elem, "nation", #ATTR_TYPE_ENUMERATION)
  addEnumNationCodes(*Attr)

  ; //
  ; passport
  ; //
  *Attr = addAttribute(*Elem, "passport", #ATTR_TYPE_STRING)
  
  ; //
  ; swrid
  ; //
  *Attr = addAttribute(*Elem, "swrid", #ATTR_TYPE_UID)  
  
  ; //
  ; subelements
  ; //
  addSubElement(*Elem, "CLUB", #False, "RECORDLIST")
  addSubElement(*Elem, "ENTRIES", #False, "MEET")
  addSubElement(*Elem, "HANDICAP")
  addSubElement(*Elem, "RESULTS", #False, "MEET")

EndProcedure

Procedure initAthletes(*psS.V3)
; ----------------------------------------
; internal   :: initialize ATHLETES element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "ATHLETES", #ELEMENT_TYPE_COLLECT, "ATHLETE")
  
EndProcedure

Procedure initClub(*psS.V3)
; ----------------------------------------
; internal   :: initialize CLUB element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "CLUB", #ELEMENT_TYPE_OBJECT)
  
  ; //
  ; code
  ; //
  *Attr = addAttribute(*Elem, "code", #ATTR_TYPE_STRING)  

  ; //
  ; name
  ; //
  *Attr = addAttribute(*Elem, "name", #ATTR_TYPE_STRING, #True)  

  ; //
  ; name.en
  ; //
  *Attr = addAttribute(*Elem, "name.en", #ATTR_TYPE_STRINGINT)  
  
  ; //
  ; nation
  ; //
  *Attr = addAttribute(*Elem, "nation", #ATTR_TYPE_ENUMERATION)
  addEnumNationCodes(*Attr)

  ; //
  ; number
  ; //
  *Attr = addAttribute(*Elem, "number", #ATTR_TYPE_NUMBER, #False, "", "!RECORDLIST")

  ; //
  ; region
  ; //
  *Attr = addAttribute(*Elem, "region", #ATTR_TYPE_STRING)  

  ; //
  ; shortname
  ; //
  *Attr = addAttribute(*Elem, "shortname", #ATTR_TYPE_STRING)  

  ; //
  ; shortname.en
  ; //
  *Attr = addAttribute(*Elem, "shortname.en", #ATTR_TYPE_STRINGINT)  

  ; //
  ; swrid
  ; //
  *Attr = addAttribute(*Elem, "swrid", #ATTR_TYPE_UID)  

  ; //
  ; type
  ; //
  *Attr = addAttribute(*Elem, "type", #ATTR_TYPE_ENUMERATION, #False, "CLUB")
  addEnumValue(*Attr, "CLUB")
  addEnumValue(*Attr, "NATIONALTEAM")
  addEnumValue(*Attr, "REGIONALTEAM")
  addEnumValue(*Attr, "UNATTACHED")

  ; //
  ; subelements
  ; //
  addSubElement(*Elem, "ATHLETES", #False, "!RECORDLIST")
  addSubElement(*Elem, "CONTACT", #False, "!RECORDLIST")
  addSubElement(*Elem, "OFFICIALS", #False, "!RECORDLIST")
  addSubElement(*Elem, "RELAYS", #False, "!RECORDLIST")
  
EndProcedure

Procedure initClubs(*psS.V3)
; ----------------------------------------
; internal   :: initialize CLUBS element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "CLUBS", #ELEMENT_TYPE_COLLECT, "CLUB")
  
EndProcedure

Procedure initConstructor(*psS.V3)
; ----------------------------------------
; internal   :: initialize CONSTRUCTOR element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "CONSTRUCTOR", #ELEMENT_TYPE_OBJECT)

  ; //
  ; name
  ; //
  *Attr = addAttribute(*Elem, "name", #ATTR_TYPE_STRING, #True)
  
  ; //
  ; registration
  ; //
  *Attr = addAttribute(*Elem, "registration", #ATTR_TYPE_STRING)
  
  ; //
  ; version
  ; //
  *Attr = addAttribute(*Elem, "version", #ATTR_TYPE_STRING, #True)

  ; //
  ; subelements
  ; //
  addSubElement(*Elem, "CONTACT", #True)
  
EndProcedure

Procedure initContact(*psS.V3)
; ----------------------------------------
; internal   :: initialize CONTACT element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "CONTACT", #ELEMENT_TYPE_OBJECT)

  ; //
  ; city
  ; //
  *Attr = addAttribute(*Elem, "city", #ATTR_TYPE_STRING)

  ; //
  ; country
  ; //
  *Attr = addAttribute(*Elem, "country", #ATTR_TYPE_STRING)

  ; //
  ; email
  ; //
  *Attr = addAttribute(*Elem, "email", #ATTR_TYPE_STRING, #True, "", "CONSTRUCTOR")
  *Attr = addAttribute(*Elem, "email", #ATTR_TYPE_STRING, #False, "", "!CONSTRUCTOR")

  ; //
  ; fax
  ; //
  *Attr = addAttribute(*Elem, "fax", #ATTR_TYPE_STRING)

  ; //
  ; internet
  ; //
  *Attr = addAttribute(*Elem, "internet", #ATTR_TYPE_STRING)

  ; //
  ; name
  ; //
  *Attr = addAttribute(*Elem, "name", #ATTR_TYPE_STRING, #False, "", "!OFFICIAL")

  ; //
  ; mobile
  ; //
  *Attr = addAttribute(*Elem, "mobile", #ATTR_TYPE_STRING)

  ; //
  ; phone
  ; //
  *Attr = addAttribute(*Elem, "phone", #ATTR_TYPE_STRING)

  ; //
  ; state
  ; //
  *Attr = addAttribute(*Elem, "state", #ATTR_TYPE_STRING)

  ; //
  ; street
  ; //
  *Attr = addAttribute(*Elem, "street", #ATTR_TYPE_STRING)

  ; //
  ; street2
  ; //
  *Attr = addAttribute(*Elem, "street2", #ATTR_TYPE_STRING)

  ; //
  ; zip
  ; //
  *Attr = addAttribute(*Elem, "zip", #ATTR_TYPE_STRING)

EndProcedure

Procedure initEntries(*psS.V3)
; ----------------------------------------
; internal   :: initialize ENTRIES element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "ENTRIES", #ELEMENT_TYPE_COLLECT, "ENTRY")
  
EndProcedure

Procedure initEntry(*psS.V3)
; ----------------------------------------
; internal   :: initialize ENTRY element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "ENTRY", #ELEMENT_TYPE_OBJECT)

  ; //
  ; agegroupid
  ; //
  *Attr = addAttribute(*Elem, "agegroupid", #ATTR_TYPE_NUMBER)
  
  ; //
  ; entrycourse
  ; //
  *Attr = addAttribute(*Elem, "entrycourse", #ATTR_TYPE_ENUMERATION)
  addEnumCourseCodes(*Attr)
  
  ; //
  ; entrytime
  ; //
  *Attr = addAttribute(*Elem, "entrytime", #ATTR_TYPE_SWIMTIME)

  ; //
  ; eventid
  ; //
  *Attr = addAttribute(*Elem, "eventid", #ATTR_TYPE_NUMBER, #True)

  ; //
  ; heatid
  ; //
  *Attr = addAttribute(*Elem, "heatid", #ATTR_TYPE_NUMBER)

  ; //
  ; lane
  ; //
  *Attr = addAttribute(*Elem, "lane", #ATTR_TYPE_NUMBER)

  ; //
  ; status
  ; //
  *Attr = addAttribute(*Elem, "status", #ATTR_TYPE_ENUMERATION)
  addEnumValue(*Attr, "EXH")
  addEnumValue(*Attr, "RJC")
  addEnumValue(*Attr, "WDR")
  
  ; //
  ; subelements
  ; //
  addSubElement(*Elem, "MEETINFO")
  addSubElement(*Elem, "RELAYPOSITIONS")
  
EndProcedure

Procedure initEvent(*psS.V3)
; ----------------------------------------
; internal   :: initialize EVENT element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "EVENT", #ELEMENT_TYPE_OBJECT)

  ; //
  ; daytime
  ; //
  *Attr = addAttribute(*Elem, "daytime", #ATTR_TYPE_DAYTIME)

  ; //
  ; eventid
  ; //
  *Attr = addAttribute(*Elem, "eventid", #ATTR_TYPE_NUMBER, #True)
  
  ; //
  ; gender
  ; //
  *Attr = addAttribute(*Elem, "gender", #ATTR_TYPE_ENUMERATION, #False, "A")
  addEnumValue(*Attr, "A")
  addEnumValue(*Attr, "M")
  addEnumValue(*Attr, "F")
  addEnumValue(*Attr, "X")
  
  ; //
  ; maxentries
  ; //
  *Attr = addAttribute(*Elem, "maxentries", #ATTR_TYPE_NUMBER)

  ; //
  ; number
  ; //
  *Attr = addAttribute(*Elem, "number", #ATTR_TYPE_NUMBER, #True)
  
  ; //
  ; order
  ; //
  *Attr = addAttribute(*Elem, "order", #ATTR_TYPE_NUMBER)

  ; //
  ; preveventid
  ; //
  *Attr = addAttribute(*Elem, "preveventid", #ATTR_TYPE_NUMBER, #False, "-1")

  ; //
  ; round
  ; //
  *Attr = addAttribute(*Elem, "round", #ATTR_TYPE_ENUMERATION, #False, "TIM")
  addEnumValue(*Attr, "TIM")
  addEnumValue(*Attr, "FHT")
  addEnumValue(*Attr, "FIN")
  addEnumValue(*Attr, "SEM")
  addEnumValue(*Attr, "QUA")
  addEnumValue(*Attr, "PRE")
  addEnumValue(*Attr, "SOP")
  addEnumValue(*Attr, "SOS")
  addEnumValue(*Attr, "SOQ")
  addEnumValue(*Attr, "TIMETRIAL")

  ; //
  ; run
  ; //
  *Attr = addAttribute(*Elem, "run", #ATTR_TYPE_NUMBER, #False, "1")

  ; //
  ; timing
  ; //
  *Attr = addAttribute(*Elem, "timing", #ATTR_TYPE_ENUMERATION)
  addEnumTimingCodes(*Attr)

  ; //
  ; type
  ; //
  *Attr = addAttribute(*Elem, "type", #ATTR_TYPE_ENUMERATION)
  addEnumValue(*Attr, "")
  addEnumValue(*Attr, "MASTERS")

  ; //
  ; subelements
  ; //
  addSubElement(*Elem, "AGEGROUPS")
  addSubElement(*Elem, "FEE")
  addSubElement(*Elem, "HEATS")
  addSubElement(*Elem, "SWIMSTYLE", #True)
  addSubElement(*Elem, "TIMESTANDARDREFS")
  
EndProcedure

Procedure initEvents(*psS.V3)
; ----------------------------------------
; internal   :: initialize EVENTS element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "EVENTS", #ELEMENT_TYPE_COLLECT, "EVENT")
  
EndProcedure

Procedure initFacility(*psS.V3)
; ----------------------------------------
; internal   :: initialize FACILITY element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "FACILITY", #ELEMENT_TYPE_OBJECT)

  ; //
  ; city
  ; //
  *Attr = addAttribute(*Elem, "city", #ATTR_TYPE_STRING, #True)

  ; //
  ; nation
  ; //
  *Attr = addAttribute(*Elem, "nation", #ATTR_TYPE_ENUMERATION, #True)
  addEnumNationCodes(*Attr)
  
  ; //
  ; name
  ; //
  *Attr = addAttribute(*Elem, "name", #ATTR_TYPE_STRING, #False, "", "!OFFICIAL")

  ; //
  ; state
  ; //
  *Attr = addAttribute(*Elem, "state", #ATTR_TYPE_STRING)

  ; //
  ; street
  ; //
  *Attr = addAttribute(*Elem, "street", #ATTR_TYPE_STRING)

  ; //
  ; street2
  ; //
  *Attr = addAttribute(*Elem, "street2", #ATTR_TYPE_STRING)

  ; //
  ; zip
  ; //
  *Attr = addAttribute(*Elem, "zip", #ATTR_TYPE_STRING)

EndProcedure

Procedure initFee(*psS.V3)
; ----------------------------------------
; internal   :: initialize FEE element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "FEE", #ELEMENT_TYPE_OBJECT)
  
  ; //
  ; currency
  ; //
  *Attr = addAttribute(*Elem, "currency", #ATTR_TYPE_ENUMERATION)
  addEnumCurrencyCodes(*Attr)

  ; //
  ; type
  ; //
  *Attr = addAttribute(*Elem, "type", #ATTR_TYPE_ENUMERATION, #True,  "", "FEES")
  addEnumValue(*Attr, "CLUB")
  addEnumValue(*Attr, "ATHLETE")
  addEnumValue(*Attr, "RELAY")
  addEnumValue(*Attr, "TEAM")
  addEnumValue(*Attr, "LATEENTRY.INDIVIDUAL")
  addEnumValue(*Attr, "LATEENTRY.RELAY")
  *Attr = addAttribute(*Elem, "type", #ATTR_TYPE_ENUMERATION, #False, "", "!FEES")
  addEnumValue(*Attr, "CLUB")
  addEnumValue(*Attr, "ATHLETE")
  addEnumValue(*Attr, "RELAY")
  addEnumValue(*Attr, "TEAM")
  addEnumValue(*Attr, "LATEENTRY.INDIVIDUAL")
  addEnumValue(*Attr, "LATEENTRY.RELAY")
  
  ; //
  ; value
  ; //
  *Attr = addAttribute(*Elem, "value", #ATTR_TYPE_CURRENCY, #True)
  
EndProcedure

Procedure initFees(*psS.V3)
; ----------------------------------------
; internal   :: initialize FEES element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "FEES", #ELEMENT_TYPE_COLLECT, "FEE")
  
EndProcedure

Procedure initHandicap(*psS.V3)
; ----------------------------------------
; internal   :: initialize HANDICAP element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "HANDICAP", #ELEMENT_TYPE_OBJECT)
  
  ; //
  ; breast
  ; //
  *Attr = addAttribute(*Elem, "breast", #ATTR_TYPE_ENUMERATION, #True)
  addEnumValue(*Attr, "0")
  addEnumValue(*Attr, "1")
  addEnumValue(*Attr, "2")
  addEnumValue(*Attr, "3")
  addEnumValue(*Attr, "4")
  addEnumValue(*Attr, "5")
  addEnumValue(*Attr, "6")
  addEnumValue(*Attr, "7")
  addEnumValue(*Attr, "8")
  addEnumValue(*Attr, "9")
  addEnumValue(*Attr, "10")
  addEnumValue(*Attr, "11")
  addEnumValue(*Attr, "12")
  addEnumValue(*Attr, "13")
  addEnumValue(*Attr, "14")
  addEnumValue(*Attr, "15")
  addEnumValue(*Attr, "GER.AB")
  addEnumValue(*Attr, "GER.GB")

  ; //
  ; exception
  ; //
  *Attr = addAttribute(*Elem, "exception", #ATTR_TYPE_STRING)

  ; //
  ; free
  ; //
  *Attr = addAttribute(*Elem, "free", #ATTR_TYPE_ENUMERATION, #True)
  addEnumValue(*Attr, "0")
  addEnumValue(*Attr, "1")
  addEnumValue(*Attr, "2")
  addEnumValue(*Attr, "3")
  addEnumValue(*Attr, "4")
  addEnumValue(*Attr, "5")
  addEnumValue(*Attr, "6")
  addEnumValue(*Attr, "7")
  addEnumValue(*Attr, "8")
  addEnumValue(*Attr, "9")
  addEnumValue(*Attr, "10")
  addEnumValue(*Attr, "11")
  addEnumValue(*Attr, "12")
  addEnumValue(*Attr, "13")
  addEnumValue(*Attr, "14")
  addEnumValue(*Attr, "15")
  addEnumValue(*Attr, "GER.AB")
  addEnumValue(*Attr, "GER.GB")

  ; //
  ; medley
  ; //
  *Attr = addAttribute(*Elem, "medley", #ATTR_TYPE_ENUMERATION, #True)
  addEnumValue(*Attr, "0")
  addEnumValue(*Attr, "1")
  addEnumValue(*Attr, "2")
  addEnumValue(*Attr, "3")
  addEnumValue(*Attr, "4")
  addEnumValue(*Attr, "5")
  addEnumValue(*Attr, "6")
  addEnumValue(*Attr, "7")
  addEnumValue(*Attr, "8")
  addEnumValue(*Attr, "9")
  addEnumValue(*Attr, "10")
  addEnumValue(*Attr, "11")
  addEnumValue(*Attr, "12")
  addEnumValue(*Attr, "13")
  addEnumValue(*Attr, "14")
  addEnumValue(*Attr, "15")
  addEnumValue(*Attr, "GER.AB")
  addEnumValue(*Attr, "GER.GB")
  
EndProcedure

Procedure initHeat(*psS.V3)
; ----------------------------------------
; internal   :: initialize HEAT element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "HEAT", #ELEMENT_TYPE_OBJECT)

  ; //
  ; agegroupid
  ; //
  *Attr = addAttribute(*Elem, "agegroupid", #ATTR_TYPE_NUMBER)

  ; //
  ; daytime
  ; //
  *Attr = addAttribute(*Elem, "daytime", #ATTR_TYPE_DAYTIME)

  ; //
  ; final
  ; //
  *Attr = addAttribute(*Elem, "final", #ATTR_TYPE_ENUMERATION)
  addEnumValue(*Attr, "A")
  addEnumValue(*Attr, "B")
  addEnumValue(*Attr, "C")
  addEnumValue(*Attr, "D")

  ; //
  ; heatid
  ; //
  *Attr = addAttribute(*Elem, "heatid", #ATTR_TYPE_NUMBER, #True)
  
  ; //
  ; number
  ; //
  *Attr = addAttribute(*Elem, "number", #ATTR_TYPE_NUMBER, #True)

  ; //
  ; order
  ; //
  *Attr = addAttribute(*Elem, "order", #ATTR_TYPE_NUMBER)

  ; //
  ; status
  ; //
  *Attr = addAttribute(*Elem, "status", #ATTR_TYPE_ENUMERATION)
  addEnumValue(*Attr, "SEEDED")
  addEnumValue(*Attr, "INOFFICIAL")
  addEnumValue(*Attr, "OFFICIAL")
  
EndProcedure

Procedure initHeats(*psS.V3)
; ----------------------------------------
; internal   :: initialize HEATS element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "HEATS", #ELEMENT_TYPE_COLLECT, "HEAT")
  
EndProcedure

Procedure initJudge(*psS.V3)
; ----------------------------------------
; internal   :: initialize JUDGE element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "JUDGE", #ELEMENT_TYPE_OBJECT)

  ; //
  ; number
  ; //
  *Attr = addAttribute(*Elem, "number", #ATTR_TYPE_NUMBER)

  ; //
  ; officialid
  ; //
  *Attr = addAttribute(*Elem, "officialid", #ATTR_TYPE_NUMBER, #True)

  ; //
  ; remarks
  ; //
  *Attr = addAttribute(*Elem, "remarks", #ATTR_TYPE_STRING)
  
  ; //
  ; role
  ; //
  *Attr = addAttribute(*Elem, "role", #ATTR_TYPE_ENUMERATION)
  addEnumValue(*Attr, "OTH")
  addEnumValue(*Attr, "MDR")
  addEnumValue(*Attr, "TDG")
  addEnumValue(*Attr, "REF")
  addEnumValue(*Attr, "STA")
  addEnumValue(*Attr, "ANN")
  addEnumValue(*Attr, "JOS")
  addEnumValue(*Attr, "CTIK")
  addEnumValue(*Attr, "TIK")
  addEnumValue(*Attr, "CFIN")
  addEnumValue(*Attr, "FIN")
  addEnumValue(*Attr, "CIOT")
  addEnumValue(*Attr, "IOT")
  addEnumValue(*Attr, "FSR")
  addEnumValue(*Attr, "COC")
  addEnumValue(*Attr, "CREC")
  addEnumValue(*Attr, "REC")
  
EndProcedure

Procedure initJudges(*psS.V3)
; ----------------------------------------
; internal   :: initialize JUDGES element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "JUDGES", #ELEMENT_TYPE_COLLECT, "JUDGE")
  
EndProcedure

Procedure initLenex(*psS.V3)
; ----------------------------------------
; internal   :: initialize LENEX element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "LENEX", #ELEMENT_TYPE_OBJECT)

  ; //
  ; version
  ; //
  *Attr = addAttribute(*Elem, "version", #ATTR_TYPE_STRING, #True)

  ; //
  ; subelements
  ; //
  addSubElement(*Elem, "CONSTRUCTOR", #True)
  addSubElement(*Elem, "MEETS")
  addSubElement(*Elem, "RECORDLISTS")
  addSubElement(*Elem, "TIMESTANDARDLISTS")
  
EndProcedure

Procedure initMeet(*psS.V3)
; ----------------------------------------
; internal   :: initialize MEET element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "MEET", #ELEMENT_TYPE_OBJECT)

  ; //
  ; altitude
  ; //
  *Attr = addAttribute(*Elem, "altitude", #ATTR_TYPE_NUMBER)

  ; //
  ; city
  ; //
  *Attr = addAttribute(*Elem, "city", #ATTR_TYPE_STRING, #True)

  ; //
  ; city.en
  ; //
  *Attr = addAttribute(*Elem, "city.en", #ATTR_TYPE_STRINGINT)

  ; //
  ; course
  ; //
  *Attr = addAttribute(*Elem, "course", #ATTR_TYPE_ENUMERATION)
  addEnumCourseCodes(*Attr)

  ; //
  ; deadline
  ; //
  *Attr = addAttribute(*Elem, "deadline", #ATTR_TYPE_DATE)

  ; //
  ; deadlinetime
  ; //
  *Attr = addAttribute(*Elem, "deadlinetime", #ATTR_TYPE_DAYTIME)

  ; //
  ; entrystartdate
  ; //
  *Attr = addAttribute(*Elem, "entrystartdate", #ATTR_TYPE_DATE)

  ; //
  ; entrytype
  ; //
  *Attr = addAttribute(*Elem, "nation", #ATTR_TYPE_ENUMERATION)
  addEnumValue(*Attr, "OPEN")
  addEnumValue(*Attr, "INVITATION")
  
  ; //
  ; hostclub
  ; //
  *Attr = addAttribute(*Elem, "hostclub", #ATTR_TYPE_STRING)

  ; //
  ; hostclub.url
  ; //
  *Attr = addAttribute(*Elem, "hostclub.url", #ATTR_TYPE_STRING)

  ; //
  ; maxentriesathlete
  ; //
  *Attr = addAttribute(*Elem, "maxentriesathlete", #ATTR_TYPE_NUMBER)

  ; //
  ; maxentriesrelay
  ; //
  *Attr = addAttribute(*Elem, "maxentriesrelay", #ATTR_TYPE_NUMBER)
  
  ; //
  ; name
  ; //
  *Attr = addAttribute(*Elem, "name", #ATTR_TYPE_STRING, #True)

  ; //
  ; name.en
  ; //
  *Attr = addAttribute(*Elem, "name.en", #ATTR_TYPE_STRINGINT)

  ; //
  ; nation
  ; //
  *Attr = addAttribute(*Elem, "nation", #ATTR_TYPE_ENUMERATION, #True)
  addEnumNationCodes(*Attr)

  ; //
  ; number
  ; //
  *Attr = addAttribute(*Elem, "number", #ATTR_TYPE_STRING)

  ; //
  ; organizer
  ; //
  *Attr = addAttribute(*Elem, "organizer", #ATTR_TYPE_STRING)

  ; //
  ; organizer.url
  ; //
  *Attr = addAttribute(*Elem, "organizer.url", #ATTR_TYPE_STRING)

  ; //
  ; reservecount
  ; //
  *Attr = addAttribute(*Elem, "reservecount", #ATTR_TYPE_NUMBER)
  
  ; //
  ; result.url
  ; //
  *Attr = addAttribute(*Elem, "result.url", #ATTR_TYPE_STRING)

  ; //
  ; startmethod
  ; //
  *Attr = addAttribute(*Elem, "startmethod", #ATTR_TYPE_NUMBER)
  
  ; //
  ; state
  ; //
  *Attr = addAttribute(*Elem, "state", #ATTR_TYPE_STRING)

  ; //
  ; swrid
  ; //
  *Attr = addAttribute(*Elem, "swrid", #ATTR_TYPE_UID)

  ; //
  ; timing
  ; //
  *Attr = addAttribute(*Elem, "timing", #ATTR_TYPE_ENUMERATION)
  addEnumTimingCodes(*Attr)
  
  ; //
  ; type
  ; //
  *Attr = addAttribute(*Elem, "type", #ATTR_TYPE_STRING)

  ; //
  ; withdrawuntil
  ; //
  *Attr = addAttribute(*Elem, "withdrawuntil", #ATTR_TYPE_DATE)
  
  ; //
  ; subelements
  ; //
  addSubElement(*Elem, "AGEDATE")
  addSubElement(*Elem, "CLUBS")
  addSubElement(*Elem, "CONTACT")
  addSubElement(*Elem, "FACILITY")
  addSubElement(*Elem, "FEES")
  addSubElement(*Elem, "POINTTABLE")
  addSubElement(*Elem, "POOL")
  addSubElement(*Elem, "QUALIFY")
  addSubElement(*Elem, "SESSIONS", #True)
  
EndProcedure

Procedure initMeetinfo(*psS.V3)
; ----------------------------------------
; internal   :: initialize MEETINFO element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "MEETINFO", #ELEMENT_TYPE_OBJECT)

  ; //
  ; approved
  ; //
  *Attr = addAttribute(*Elem, "approved", #ATTR_TYPE_STRING, #False, "", "ENTRY|RELAYPOSITION")

  ; //
  ; city
  ; //
  *Attr = addAttribute(*Elem, "city", #ATTR_TYPE_STRING, #True, "", "RECORD")
  *Attr = addAttribute(*Elem, "city", #ATTR_TYPE_STRING, #False, "", "!RECORD")

  ; //
  ; course
  ; //
  *Attr = addAttribute(*Elem, "course", #ATTR_TYPE_ENUMERATION, #False, "", "ENTRY|RELAYPOSITION")
  addEnumCourseCodes(*Attr)

  ; //
  ; date
  ; //
  *Attr = addAttribute(*Elem, "date", #ATTR_TYPE_DATE, #True, "", "RECORD")
  *Attr = addAttribute(*Elem, "date", #ATTR_TYPE_DATE, #False, "", "!RECORD")

  ; //
  ; name
  ; //
  *Attr = addAttribute(*Elem, "name", #ATTR_TYPE_STRING)

  ; //
  ; nation
  ; //
  *Attr = addAttribute(*Elem, "nation", #ATTR_TYPE_ENUMERATION, #True, "", "RECORD")
  addEnumNationCodes(*Attr)
  *Attr = addAttribute(*Elem, "nation", #ATTR_TYPE_ENUMERATION, #False, "", "!RECORD")
  addEnumNationCodes(*Attr)

  ; //
  ; qualificationtime
  ; //
  *Attr = addAttribute(*Elem, "qualificationtime", #ATTR_TYPE_SWIMTIME, #False, "", "ENTRY|RELAYPOSITION")

  ; //
  ; state
  ; //
  *Attr = addAttribute(*Elem, "state", #ATTR_TYPE_STRING)

  ; //
  ; subelements
  ; //
  addSubElement(*Elem, "POOL")
  
EndProcedure

Procedure initMeets(*psS.V3)
; ----------------------------------------
; internal   :: initialize MEETS element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "MEETS", #ELEMENT_TYPE_COLLECT, "MEET")
  
EndProcedure

Procedure initOfficial(*psS.V3)
; ----------------------------------------
; internal   :: initialize OFFICIAL element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "OFFICIAL", #ELEMENT_TYPE_OBJECT)
  
  ; //
  ; firstname
  ; //
  *Attr = addAttribute(*Elem, "firstname", #ATTR_TYPE_STRING, #True)

  ; //
  ; gender
  ; //
  *Attr = addAttribute(*Elem, "gender", #ATTR_TYPE_ENUMERATION, #True)
  addEnumValue(*Attr, "M")
  addEnumValue(*Attr, "F")

  ; //
  ; grade
  ; //
  *Attr = addAttribute(*Elem, "grade", #ATTR_TYPE_STRING)

  ; //
  ; lastname
  ; //
  *Attr = addAttribute(*Elem, "lastname", #ATTR_TYPE_STRING, #True)

  ; //
  ; nameprefix
  ; //
  *Attr = addAttribute(*Elem, "nameprefix", #ATTR_TYPE_STRING)
  
  ; //
  ; nation
  ; //
  *Attr = addAttribute(*Elem, "nation", #ATTR_TYPE_ENUMERATION)
  addEnumNationCodes(*Attr)

  ; //
  ; officialid
  ; //
  *Attr = addAttribute(*Elem, "officialid", #ATTR_TYPE_NUMBER, #True)
  
  ; //
  ; passport
  ; //
  *Attr = addAttribute(*Elem, "passport", #ATTR_TYPE_STRING)

  ; //
  ; subelements
  ; //
  addSubElement(*Elem, "CONTACT")
  
EndProcedure

Procedure initOfficials(*psS.V3)
; ----------------------------------------
; internal   :: initialize OFFICIALS element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "OFFICIALS", #ELEMENT_TYPE_COLLECT, "OFFICIAL")
  
EndProcedure

Procedure initPointtable(*psS.V3)
; ----------------------------------------
; internal   :: initialize POINTTABLE element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "POINTTABLE", #ELEMENT_TYPE_OBJECT)

  ; //
  ; name
  ; //
  *Attr = addAttribute(*Elem, "name", #ATTR_TYPE_STRING, #True)

  ; //
  ; pointtableid
  ; //
  *Attr = addAttribute(*Elem, "pointtableid", #ATTR_TYPE_NUMBER)

  ; //
  ; version
  ; //
  *Attr = addAttribute(*Elem, "version", #ATTR_TYPE_STRING, #True)
  
EndProcedure

Procedure initPool(*psS.V3)
; ----------------------------------------
; internal   :: initialize POOL element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "POOL", #ELEMENT_TYPE_OBJECT)

  ; //
  ; lanemax
  ; //
  *Attr = addAttribute(*Elem, "lanemax", #ATTR_TYPE_NUMBER)

  ; //
  ; lanemin
  ; //
  *Attr = addAttribute(*Elem, "lanemin", #ATTR_TYPE_NUMBER)

  ; //
  ; temperature
  ; //
  *Attr = addAttribute(*Elem, "temperature", #ATTR_TYPE_NUMBER)

  ; //
  ; type
  ; //
  *Attr = addAttribute(*Elem, "type", #ATTR_TYPE_ENUMERATION)
  addEnumValue(*Attr, "INDOOR")
  addEnumValue(*Attr, "OUTDOOR")
  addEnumValue(*Attr, "LAKE")
  addEnumValue(*Attr, "OCEAN")
  
EndProcedure  

Procedure initQualify(*psS.V3)
; ----------------------------------------
; internal   :: initialize QUALIFY element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "QUALIFY", #ELEMENT_TYPE_OBJECT)

  ; //
  ; conversion
  ; //
  *Attr = addAttribute(*Elem, "conversion", #ATTR_TYPE_ENUMERATION, #False, "NONE")
  addEnumValue(*Attr, "NONE")
  addEnumValue(*Attr, "FINA_POINTS")
  addEnumValue(*Attr, "PERCENT_LINEAR")
  addEnumValue(*Attr, "NON_CONFORMING_LAST")

  ; //
  ; from
  ; //
  *Attr = addAttribute(*Elem, "from", #ATTR_TYPE_DATE, #True)

  ; //
  ; percent
  ; //
  *Attr = addAttribute(*Elem, "percent", #ATTR_TYPE_NUMBER)

  ; //
  ; until
  ; //
  *Attr = addAttribute(*Elem, "until", #ATTR_TYPE_DATE)
  
EndProcedure

Procedure initRanking(*psS.V3)
; ----------------------------------------
; internal   :: initialize RANKING element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "RANKING", #ELEMENT_TYPE_OBJECT)

  ; //
  ; order
  ; //
  *Attr = addAttribute(*Elem, "order", #ATTR_TYPE_NUMBER)

  ; //
  ; place
  ; //
  *Attr = addAttribute(*Elem, "place", #ATTR_TYPE_NUMBER, #True)

  ; //
  ; resultid
  ; //
  *Attr = addAttribute(*Elem, "resultid", #ATTR_TYPE_NUMBER, #True)
  
EndProcedure

Procedure initRankings(*psS.V3)
; ----------------------------------------
; internal   :: initialize RANKINGS element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "RANKINGS", #ELEMENT_TYPE_COLLECT, "RANKING")
  
EndProcedure

Procedure initRecord(*psS.V3)
; ----------------------------------------
; internal   :: initialize RECORD element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "RECORD", #ELEMENT_TYPE_OBJECT)

  ; //
  ; comment
  ; //
  *Attr = addAttribute(*Elem, "comment", #ATTR_TYPE_STRING)
  
  ; //
  ; swimtime
  ; //
  *Attr = addAttribute(*Elem, "swimtime", #ATTR_TYPE_SWIMTIME, #True)  

  ; //
  ; status
  ; //
  *Attr = addAttribute(*Elem, "status", #ATTR_TYPE_STRING)

  ; //
  ; subelements
  ; //
  addSubElement(*Elem, "ATHLETE")
  addSubElement(*Elem, "MEETINFO")
  addSubElement(*Elem, "RELAY")
  addSubElement(*Elem, "SPLITS")
  addSubElement(*Elem, "SWIMSTYLE")
  
EndProcedure

Procedure initRecordlist(*psS.V3)
; ----------------------------------------
; internal   :: initialize RECORDLIST element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "RECORDLIST", #ELEMENT_TYPE_OBJECT)

  ; //
  ; course
  ; //
  *Attr = addAttribute(*Elem, "course", #ATTR_TYPE_ENUMERATION, #True)
  addEnumCourseCodes(*Attr)

  ; //
  ; gender
  ; //
  *Attr = addAttribute(*Elem, "gender", #ATTR_TYPE_ENUMERATION, #True)
  addEnumValue(*Attr, "M")
  addEnumValue(*Attr, "F")
  addEnumValue(*Attr, "X")

  ; //
  ; handicap
  ; //
  *Attr = addAttribute(*Elem, "handicap", #ATTR_TYPE_ENUMERATION)
  addEnumValue(*Attr, "0")
  addEnumValue(*Attr, "1")
  addEnumValue(*Attr, "2")
  addEnumValue(*Attr, "3")
  addEnumValue(*Attr, "4")
  addEnumValue(*Attr, "5")
  addEnumValue(*Attr, "6")
  addEnumValue(*Attr, "7")
  addEnumValue(*Attr, "8")
  addEnumValue(*Attr, "9")
  addEnumValue(*Attr, "10")
  addEnumValue(*Attr, "11")
  addEnumValue(*Attr, "12")
  addEnumValue(*Attr, "13")
  addEnumValue(*Attr, "14")
  addEnumValue(*Attr, "15")
  addEnumValue(*Attr, "20")
  addEnumValue(*Attr, "34")
  addEnumValue(*Attr, "49")
  
  ; //
  ; name
  ; //
  *Attr = addAttribute(*Elem, "name", #ATTR_TYPE_STRING, #True)

  ; //
  ; nation
  ; //
  *Attr = addAttribute(*Elem, "nation", #ATTR_TYPE_STRING)

  ; //
  ; order
  ; //
  *Attr = addAttribute(*Elem, "order", #ATTR_TYPE_NUMBER)

  ; //
  ; region
  ; //
  *Attr = addAttribute(*Elem, "region", #ATTR_TYPE_STRING)

  ; //
  ; updated
  ; //
  *Attr = addAttribute(*Elem, "updated", #ATTR_TYPE_DATE)

  ; //
  ; type
  ; //
  *Attr = addAttribute(*Elem, "type", #ATTR_TYPE_STRING)

  ; //
  ; subelements
  ; //
  addSubElement(*Elem, "AGEGROUPS")
  addSubElement(*Elem, "RECORDS", #True)
  
EndProcedure

Procedure initRecordlists(*psS.V3)
; ----------------------------------------
; internal   :: initialize RECORDLISTS element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "RECORDLISTS", #ELEMENT_TYPE_COLLECT, "RECORDLIST")
  
EndProcedure

Procedure initRecords(*psS.V3)
; ----------------------------------------
; internal   :: initialize RECORDS element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "RECORDS", #ELEMENT_TYPE_COLLECT, "RECORD")
  
EndProcedure

Procedure initRelay(*psS.V3)
; ----------------------------------------
; internal   :: initialize RELAY element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "RELAY", #ELEMENT_TYPE_OBJECT)

  ; //
  ; agemax
  ; //
  *Attr = addAttribute(*Elem, "agemax", #ATTR_TYPE_NUMBER, #True, "", "MEET")

  ; //
  ; agemin
  ; //
  *Attr = addAttribute(*Elem, "agemin", #ATTR_TYPE_NUMBER, #True, "", "MEET")

  ; //
  ; agetotalmax
  ; //
  *Attr = addAttribute(*Elem, "agetotalmax", #ATTR_TYPE_NUMBER, #True, "", "MEET")

  ; //
  ; agetotalmin
  ; //
  *Attr = addAttribute(*Elem, "agetotalmin", #ATTR_TYPE_NUMBER, #True, "", "MEET")

  ; //
  ; gender
  ; //
  *Attr = addAttribute(*Elem, "gender", #ATTR_TYPE_ENUMERATION, #True, "", "MEET")
  addEnumValue(*Attr, "M")
  addEnumValue(*Attr, "F")
  addEnumValue(*Attr, "X")
  
  ; //
  ; handicap
  ; //
  *Attr = addAttribute(*Elem, "handicap", #ATTR_TYPE_ENUMERATION, #False, "0", "MEET")
  addEnumValue(*Attr, "0")
  addEnumValue(*Attr, "14")
  addEnumValue(*Attr, "20")
  addEnumValue(*Attr, "34")
  addEnumValue(*Attr, "49")

  ; //
  ; name
  ; //
  *Attr = addAttribute(*Elem, "name", #ATTR_TYPE_STRING)

  ; //
  ; number
  ; //
  *Attr = addAttribute(*Elem, "number", #ATTR_TYPE_NUMBER, #False, "", "MEET")

  ; //
  ; subelements
  ; //
  addSubElement(*Elem, "CLUB", #False, "RECORD")
  addSubElement(*Elem, "ENTRIES", #False, "MEET")
  addSubElement(*Elem, "RELAYPOSITIONS", #False, "RECORD")
  addSubElement(*Elem, "RESULTS", #False, "MEET")
  
EndProcedure

Procedure initRelays(*psS.V3)
; ----------------------------------------
; internal   :: initialize RELAYS element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "RELAYS", #ELEMENT_TYPE_COLLECT, "RELAY")
  
EndProcedure

Procedure initRelayposition(*psS.V3)
; ----------------------------------------
; internal   :: initialize RELAYPOSITION element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "RELAYPOSITION", #ELEMENT_TYPE_OBJECT)

  ; //
  ; athleteid
  ; //
  *Attr = addAttribute(*Elem, "athleteid", #ATTR_TYPE_NUMBER, #False, "", "MEET")

  ; //
  ; number
  ; //
  *Attr = addAttribute(*Elem, "number", #ATTR_TYPE_NUMBER, #True)

  ; //
  ; reactiontime
  ; //
  *Attr = addAttribute(*Elem, "reactiontime", #ATTR_TYPE_REACTTIME)

  ; //
  ; status
  ; //
  *Attr = addAttribute(*Elem, "status", #ATTR_TYPE_ENUMERATION)
  addEnumValue(*Attr, "DSQ")
  addEnumValue(*Attr, "DNF")
  
EndProcedure

Procedure initRelaypositions(*psS.V3)
; ----------------------------------------
; internal   :: initialize RELAYPOSITIONS element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "RELAYPOSITIONS", #ELEMENT_TYPE_COLLECT, "RELAYPOSITION")
  
EndProcedure

Procedure initResult(*psS.V3)
; ----------------------------------------
; internal   :: initialize RESULT element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "RESULT", #ELEMENT_TYPE_OBJECT)

  ; //
  ; comment
  ; //
  *Attr = addAttribute(*Elem, "comment", #ATTR_TYPE_STRING)

  ; //
  ; eventid
  ; //
  *Attr = addAttribute(*Elem, "eventid", #ATTR_TYPE_NUMBER, #True)

  ; //
  ; heatid
  ; //
  *Attr = addAttribute(*Elem, "heatid", #ATTR_TYPE_NUMBER)

  ; //
  ; lane
  ; //
  *Attr = addAttribute(*Elem, "lane", #ATTR_TYPE_NUMBER)

  ; //
  ; points
  ; //
  *Attr = addAttribute(*Elem, "points", #ATTR_TYPE_NUMBER)

  ; //
  ; reactiontime
  ; //
  *Attr = addAttribute(*Elem, "reactiontime", #ATTR_TYPE_REACTTIME)

  ; //
  ; resultid
  ; //
  *Attr = addAttribute(*Elem, "resultid", #ATTR_TYPE_NUMBER, #True)

  ; //
  ; status
  ; //
  *Attr = addAttribute(*Elem, "status", #ATTR_TYPE_ENUMERATION)
  addEnumValue(*Attr, "EXH")
  addEnumValue(*Attr, "DSQ")
  addEnumValue(*Attr, "DNS")
  addEnumValue(*Attr, "DNF")
  addEnumValue(*Attr, "WDR")

  ; //
  ; swimtime
  ; //
  *Attr = addAttribute(*Elem, "swimtime", #ATTR_TYPE_SWIMTIME, #True)

  ; //
  ; subelements
  ; //
  addSubElement(*Elem, "RELAYPOSITIONS")
  addSubElement(*Elem, "SPLITS")

EndProcedure

Procedure initResults(*psS.V3)
; ----------------------------------------
; internal   :: initialize RESULTS element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "RESULTS", #ELEMENT_TYPE_COLLECT, "RESULT")
  
EndProcedure

Procedure initSession(*psS.V3)
; ----------------------------------------
; internal   :: initialize SESSION element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "SESSION", #ELEMENT_TYPE_OBJECT)

  ; //
  ; course
  ; //
  *Attr = addAttribute(*Elem, "course", #ATTR_TYPE_ENUMERATION)
  addEnumCourseCodes(*Attr)

  ; //
  ; date
  ; //
  *Attr = addAttribute(*Elem, "date", #ATTR_TYPE_DATE, #True)

  ; //
  ; daytime
  ; //
  *Attr = addAttribute(*Elem, "daytime", #ATTR_TYPE_DAYTIME)

  ; //
  ; endtime
  ; //
  *Attr = addAttribute(*Elem, "endtime", #ATTR_TYPE_DAYTIME)

  ; //
  ; maxentriesathlete
  ; //
  *Attr = addAttribute(*Elem, "maxentriesathlete", #ATTR_TYPE_NUMBER)

  ; //
  ; maxentriesrelay
  ; //
  *Attr = addAttribute(*Elem, "maxentriesrelay", #ATTR_TYPE_NUMBER)
  
  ; //
  ; name
  ; //
  *Attr = addAttribute(*Elem, "name", #ATTR_TYPE_STRING)

  ; //
  ; number
  ; //
  *Attr = addAttribute(*Elem, "number", #ATTR_TYPE_NUMBER, #True)

  ; //
  ; officialmeeting
  ; //
  *Attr = addAttribute(*Elem, "officialmeeting", #ATTR_TYPE_DAYTIME)

  ; //
  ; remarksjudge
  ; //
  *Attr = addAttribute(*Elem, "remarksjudge", #ATTR_TYPE_STRING)
  
  ; //
  ; teamleadermeeting
  ; //
  *Attr = addAttribute(*Elem, "teamleadermeeting", #ATTR_TYPE_DAYTIME)

  ; //
  ; timing
  ; //
  *Attr = addAttribute(*Elem, "timing", #ATTR_TYPE_ENUMERATION)
  addEnumTimingCodes(*Attr)
  
  ; //
  ; warmupfrom
  ; //
  *Attr = addAttribute(*Elem, "warmupfrom", #ATTR_TYPE_DAYTIME)

  ; //
  ; warmupuntil
  ; //
  *Attr = addAttribute(*Elem, "warmupuntil", #ATTR_TYPE_DAYTIME)

  ; //
  ; subelements
  ; //
  addSubElement(*Elem, "EVENTS", #True)
  addSubElement(*Elem, "FEES")
  addSubElement(*Elem, "JUDGES")
  addSubElement(*Elem, "POOL")
  
EndProcedure

Procedure initSessions(*psS.V3)
; ----------------------------------------
; internal   :: initialize SESSIONS element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "SESSIONS", #ELEMENT_TYPE_COLLECT, "SESSION")
  
EndProcedure

Procedure initSplit(*psS.V3)
; ----------------------------------------
; internal   :: initialize SPLIT element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "SPLIT", #ELEMENT_TYPE_OBJECT)

  ; //
  ; distance
  ; //
  *Attr = addAttribute(*Elem, "distance", #ATTR_TYPE_NUMBER, #True)

  ; //
  ; swimtime
  ; //
  *Attr = addAttribute(*Elem, "swimtime", #ATTR_TYPE_SWIMTIME, #True)
  
EndProcedure

Procedure initSplits(*psS.V3)
; ----------------------------------------
; internal   :: initialize SPLITS element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "SPLITS", #ELEMENT_TYPE_COLLECT, "SPLIT")
  
EndProcedure

Procedure initSwimstyle(*psS.V3)
; ----------------------------------------
; internal   :: initialize SWIMSTYLE element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "SWIMSTYLE", #ELEMENT_TYPE_OBJECT)

  ; //
  ; distance
  ; //
  *Attr = addAttribute(*Elem, "distance", #ATTR_TYPE_NUMBER, #True)

  ; //
  ; name
  ; //
  *Attr = addAttribute(*Elem, "name", #ATTR_TYPE_STRING)

  ; //
  ; relaycount
  ; //
  *Attr = addAttribute(*Elem, "relaycount", #ATTR_TYPE_NUMBER, #True)

  ; //
  ; stroke
  ; //
  *Attr = addAttribute(*Elem, "stroke", #ATTR_TYPE_ENUMERATION)
  addEnumValue(*Attr, "APNEA")
  addEnumValue(*Attr, "BACK")
  addEnumValue(*Attr, "BIFINS")
  addEnumValue(*Attr, "BREAST")
  addEnumValue(*Attr, "FLY")
  addEnumValue(*Attr, "FREE")
  addEnumValue(*Attr, "IMMERSION")
  addEnumValue(*Attr, "IMRELAY")
  addEnumValue(*Attr, "MEDLEY")
  addEnumValue(*Attr, "SURFACE")
  addEnumValue(*Attr, "UNKNOWN")

  ; //
  ; swimstyleid
  ; //
  *Attr = addAttribute(*Elem, "swimstyleid", #ATTR_TYPE_NUMBER)

  ; //
  ; technique
  ; //
  *Attr = addAttribute(*Elem, "technique", #ATTR_TYPE_ENUMERATION)
  addEnumValue(*Attr, "DIVE")
  addEnumValue(*Attr, "GLIDE")
  addEnumValue(*Attr, "KICK")
  addEnumValue(*Attr, "PULL")
  addEnumValue(*Attr, "START")
  addEnumValue(*Attr, "TURN")
  
EndProcedure

Procedure initTimestandard(*psS.V3)
; ----------------------------------------
; internal   :: initialize TIMESTANDARD element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------
  
  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "TIMESTANDARD", #ELEMENT_TYPE_OBJECT)

  ; //
  ; swimtime
  ; //
  *Attr = addAttribute(*Elem, "swimtime", #ATTR_TYPE_SWIMTIME, #True)

  ; //
  ; subelements
  ; //
  addSubElement(*Elem, "SWIMSTYLE", #True)
  
EndProcedure

Procedure initTimestandards(*psS.V3)
; ----------------------------------------
; internal   :: initialize TIMESTANDARDS element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "TIMESTANDARDS", #ELEMENT_TYPE_COLLECT, "TIMESTANDARD")
  
EndProcedure

Procedure initTimestandardlist(*psS.V3)
; ----------------------------------------
; internal   :: initialize TIMESTANDARDLIST element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------

  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "TIMESTANDARDLIST", #ELEMENT_TYPE_OBJECT)

  ; //
  ; course
  ; //
  *Attr = addAttribute(*Elem, "course", #ATTR_TYPE_ENUMERATION, #True)
  addEnumCourseCodes(*Attr)

  ; //
  ; gender
  ; //
  *Attr = addAttribute(*Elem, "gender", #ATTR_TYPE_ENUMERATION, #True)
  addEnumValue(*Attr, "M")
  addEnumValue(*Attr, "F")
  addEnumValue(*Attr, "X")

  ; //
  ; handicap
  ; //
  *Attr = addAttribute(*Elem, "handicap", #ATTR_TYPE_ENUMERATION)
  addEnumValue(*Attr, "0")
  addEnumValue(*Attr, "1")
  addEnumValue(*Attr, "2")
  addEnumValue(*Attr, "3")
  addEnumValue(*Attr, "4")
  addEnumValue(*Attr, "5")
  addEnumValue(*Attr, "6")
  addEnumValue(*Attr, "7")
  addEnumValue(*Attr, "8")
  addEnumValue(*Attr, "9")
  addEnumValue(*Attr, "10")
  addEnumValue(*Attr, "11")
  addEnumValue(*Attr, "12")
  addEnumValue(*Attr, "13")
  addEnumValue(*Attr, "14")
  addEnumValue(*Attr, "15")
  addEnumValue(*Attr, "20")
  addEnumValue(*Attr, "34")
  addEnumValue(*Attr, "49")
  
  ; //
  ; name
  ; //
  *Attr = addAttribute(*Elem, "name", #ATTR_TYPE_STRING, #True)

  ; //
  ; timestandardlistid
  ; //
  *Attr = addAttribute(*Elem, "timestandardlistid", #ATTR_TYPE_NUMBER, #True)

  ; //
  ; type
  ; //
  *Attr = addAttribute(*Elem, "type", #ATTR_TYPE_ENUMERATION, #False, "MAXIMUM")
  addEnumValue(*Attr, "DEFAULT")
  addEnumValue(*Attr, "MAXIMUM")
  addEnumValue(*Attr, "MINIMUM")

  ; //
  ; subelements
  ; //
  addSubElement(*Elem, "AGEGROUP")
  addSubElement(*Elem, "TIMESTANDARDS", #True)
  
EndProcedure

Procedure initTimestandardlists(*psS.V3)
; ----------------------------------------
; internal   :: initialize TIMESTANDARDLISTS element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "TIMESTANDARDLISTS", #ELEMENT_TYPE_COLLECT, "TIMESTANDARDLIST")
  
EndProcedure

Procedure initTimestandardref(*psS.V3)
; ----------------------------------------
; internal   :: initialize TIMESTANDARDREF element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  Protected *Elem.ELEMENT,
            *Attr.ATTRIBUTE
; ----------------------------------------

  ; //
  ; element
  ; //
  *Elem = defineElement(*psS, "TIMESTANDARDREF", #ELEMENT_TYPE_OBJECT)

  ; //
  ; timestandardlistid
  ; //
  *Attr = addAttribute(*Elem, "timestandardlistid", #ATTR_TYPE_NUMBER, #True)

  ; //
  ; marker
  ; //
  *Attr = addAttribute(*Elem, "marker", #ATTR_TYPE_STRING)

  ; //
  ; subelements
  ; //
  addSubElement(*Elem, "FEE")
  
EndProcedure

Procedure initTimestandardrefs(*psS.V3)
; ----------------------------------------
; internal   :: initialize TIMESTANDARDREFS element
; param      :: *psS - schema structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; element
  ; //
  defineElement(*psS, "TIMESTANDARDREFS", #ELEMENT_TYPE_COLLECT, "TIMESTANDARDREF")
  
EndProcedure

;- >>> public schema functions <<<

Procedure.i getSchema()
; ----------------------------------------
; public     :: create the LENEX3 schema
; param      :: (none)
; returns    :: LENEX3 schema structure pointer
; ----------------------------------------
  Protected *sS.V3
; ----------------------------------------
  
  ; //
  ; allocate schema memory
  ; //
  *sS = AllocateStructure(V3)
  
  initAgedate(*sS)
  initAgegroup(*sS)
  initAgegroups(*sS)
  initAthlete(*sS)
  initAthletes(*sS)
  initClub(*sS)
  initClubs(*sS)
  initConstructor(*sS)
  initContact(*sS)
  initEntries(*sS)
  initEntry(*sS)
  initEvent(*sS)
  initEvents(*sS)
  initFacility(*sS)
  initFee(*sS)
  initFees(*sS)
  initHandicap(*sS)
  initHeat(*sS)
  initHeats(*sS)
  initJudge(*sS)
  initJudges(*sS)
  initLenex(*sS)
  initMeet(*sS)
  initMeetinfo(*sS)
  initMeets(*sS)
  initOfficial(*sS)
  initOfficials(*sS)
  initPointtable(*sS)
  initPool(*sS)
  initQualify(*sS)
  initRanking(*sS)
  initRankings(*sS)
  initRecord(*sS)
  initRecordlist(*sS)
  initRecordlists(*sS)
  initRecords(*sS)
  initRelay(*sS)
  initRelays(*sS)
  initRelayposition(*sS)
  initRelaypositions(*sS)
  initResult(*sS)
  initResults(*sS)
  initSession(*sS)
  initSessions(*sS)
  initSplit(*sS)
  initSplits(*sS)
  initSwimstyle(*sS)
  initTimestandard(*sS)
  initTimestandards(*sS)
  initTimestandardlist(*sS)
  initTimestandardlists(*sS)
  initTimestandardref(*sS)
  initTimestandardrefs(*sS)
  
  ProcedureReturn *sS
  
EndProcedure

;- >>> public element functions <<<

Procedure.i getElement(*psSchema.V3, pzName.s)
; ----------------------------------------
; public     :: get a schema element
; param      :: *psSchema - schema structure
;               pzName    - element name
; returns    :: (i) LENEX3 schema element pointer
; ----------------------------------------
  Protected *Elem = #Null
; ----------------------------------------
  
  pzName = UCase(pzName)
  
  ForEach *psSchema\Elem()
    If *psSchema\Elem()\zName = pzName
      *Elem = @*psSchema\Elem()
      Break
    EndIf
  Next
  
  ProcedureReturn *Elem

EndProcedure

Procedure.i getElementType(*psElement.ELEMENT)
; ----------------------------------------
; public     :: get the element's type
; param      :: *psElement - schema element pointer
; returns    :: (i) element type
; ----------------------------------------

  ProcedureReturn *psElement\iType
  
EndProcedure

Procedure.s getElementCollect(*psElement.ELEMENT)
; ----------------------------------------
; public     :: get the element's collected element
; param      :: *psElement - schema element pointer
; returns    :: (s) collected element name
; ----------------------------------------

  ProcedureReturn *psElement\zCollect
  
EndProcedure

;- >>> public sub element functions <<<

Procedure examineSubElements(*psElement.ELEMENT)
; ----------------------------------------
; public     :: loop through the element's sub elements
; param      :: *psElement - schema element pointer
; returns    :: (nothing)
; ----------------------------------------

  ResetList(*psElement\Elem())

EndProcedure

Procedure.i nextSubElement(*psElement.ELEMENT)
; ----------------------------------------
; public     :: set the current sub element to the next one
; param      :: *psElement - schema element pointer
; returns    :: (i)  0 - no more sub elements
;                   >0 - more sub elements available
; ----------------------------------------
  
  ProcedureReturn NextElement(*psElement\Elem())
  
EndProcedure

Procedure.s getSubElementName(*psElement.ELEMENT)
; ----------------------------------------
; public     :: return the name of the current sub element
; param      :: *psElement - schema element pointer
; returns    :: (s) element name
; ----------------------------------------
  
  If ListIndex(*psElement\Elem())
    ProcedureReturn *psElement\Elem()\zName
  Else
    ProcedureReturn ""
  EndIf

EndProcedure

Procedure.s getSubElementContext(*psElement.ELEMENT)
; ----------------------------------------
; public     :: return the context definition of the current sub element
; param      :: *psElement - schema element pointer
; returns    :: (s) sub element context definition
; ----------------------------------------

  If ListIndex(*psElement\Elem())
    ProcedureReturn *psElement\Elem()\zContext
  Else
    ProcedureReturn ""
  EndIf

EndProcedure

Procedure.i getSubElementRequired(*psElement.ELEMENT)
; ----------------------------------------
; public     :: return the required state of the current sub element
; param      :: *psElement - schema element pointer
; returns    :: (i) #True  - sub element is required
;                   #False - sub element is not required
; ----------------------------------------

  If ListIndex(*psElement\Elem())
    ProcedureReturn *psElement\Elem()\iRequired
  Else
    ProcedureReturn #False
  EndIf

EndProcedure

;- >>> public attribute functions <<<

Procedure examineAttributes(*psElement.ELEMENT)
; ----------------------------------------
; public     :: loop through the element's attributes
; param      :: *psElement - schema element pointer
; returns    :: (nothing)
; ----------------------------------------

  ResetList(*psElement\Attr())

EndProcedure

Procedure.i nextAttribute(*psElement.ELEMENT)
; ----------------------------------------
; public     :: set the current attribute to the next one
; param      :: *psElement - schema element pointer
; returns    :: (i)  0 - no more attributes
;                   >0 - more attributes available
; ----------------------------------------
  
  ProcedureReturn NextElement(*psElement\Attr())
  
EndProcedure

Procedure.i selectAttribute(*psElement.ELEMENT, pzName.s)
; ----------------------------------------
; public     :: set the current attribute by name
; param      :: *psElement - schema element pointer
;               pzName     - atribute name
; returns    :: (i)  0 - attribute not found
;                    1 - attribute found
; ----------------------------------------
  
  pzName = UCase(pzName)
  
  PushListPosition(*psElement\Attr())
  ForEach *psElement\Attr()
    If *psElement\Attr()\zName = pzName
      ProcedureReturn 1
    EndIf
  Next
  PopListPosition(*psElement\Attr())
  
  ProcedureReturn 0
  
EndProcedure

Procedure.i getAttributeType(*psElement.ELEMENT)
; ----------------------------------------
; public     :: return the type of the current attribute
; param      :: *psElement - schema element pointer
; returns    :: (i) attribute type
; ----------------------------------------

  If ListIndex(*psElement\Attr())
    ProcedureReturn *psElement\Attr()\iType
  Else
    ProcedureReturn -1
  EndIf

EndProcedure

Procedure.s getAttributeName(*psElement.ELEMENT)
; ----------------------------------------
; public     :: return the name of the current attribute
; param      :: *psElement - schema element pointer
; returns    :: (s) attribute name
; ----------------------------------------

  If ListIndex(*psElement\Attr())
    ProcedureReturn *psElement\Attr()\zName
  Else
    ProcedureReturn ""
  EndIf

EndProcedure

Procedure.s getAttributeContext(*psElement.ELEMENT)
; ----------------------------------------
; public     :: return the context definition of the current attribute
; param      :: *psElement - schema element pointer
; returns    :: (s) attribute context definition
; ----------------------------------------

  If ListIndex(*psElement\Attr())
    ProcedureReturn *psElement\Attr()\zContext
  Else
    ProcedureReturn ""
  EndIf

EndProcedure

Procedure.s getAttributeDefault(*psElement.ELEMENT)
; ----------------------------------------
; public     :: return the default value of the current attribute
; param      :: *psElement - schema element pointer
; returns    :: (s) attribute default value
; ----------------------------------------

  If ListIndex(*psElement\Attr())
    ProcedureReturn *psElement\Attr()\zDefault
  Else
    ProcedureReturn ""
  EndIf

EndProcedure

Procedure.i getAttributeRequired(*psElement.ELEMENT)
; ----------------------------------------
; public     :: return the required state of the current attribute
; param      :: *psElement - schema element pointer
; returns    :: (i) #True  - attribute is required
;                   #False - attribute is not required
; ----------------------------------------

  If ListIndex(*psElement\Attr())
    ProcedureReturn *psElement\Attr()\iRequired
  Else
    ProcedureReturn #False
  EndIf

EndProcedure

Procedure.i examineAttributeEnums(*psElement.ELEMENT)
; ----------------------------------------
; public     :: loop through the attribute's enum values
; param      :: *psElement - schema element pointer
; returns    :: (i)  1 - attribute is of type enumeration
;                    0 - attribute has other type
;                   -1 - no attribute selected
; ----------------------------------------

  If Not ListIndex(*psElement\Attr())
    ProcedureReturn -1
  EndIf
  
  If *psElement\Attr()\iType <> #ATTR_TYPE_ENUMERATION
    ProcedureReturn 0
  EndIf
  
  ResetList(*psElement\Attr()\Enum())
  
  ProcedureReturn 1
  
EndProcedure

Procedure.i nextAttributeEnum(*psElement.ELEMENT)
; ----------------------------------------
; public     :: set the current attribute enum to the next one
; param      :: *psElement - schema element pointer
; returns    :: (i)  0 - no more attribute enums
;                   >0 - more attribute enums available
; ----------------------------------------
  
  ProcedureReturn NextElement(*psElement\Attr()\Enum())
  
EndProcedure

Procedure.s getAttributeEnumValue(*psElement.ELEMENT)
; ----------------------------------------
; public     :: return the value of the current attribute enum
; param      :: *psElement - schema element pointer
; returns    :: (s) attribute enum value or empty if error
; ----------------------------------------

  If ListIndex(*psElement\Attr()) And ListIndex(*psElement\Attr()\Enum())
    ProcedureReturn *psElement\Attr()\Enum()
  Else
    ProcedureReturn ""
  EndIf

EndProcedure

EndModule