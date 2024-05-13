; ###########################################################
; ################ LENEX 3 PARSER PB MODULE #################
; ###########################################################

;   written by hgzh, 2024

;   This module provides a parser for LENEX 3 data. The data
;   can be parsed from a compressed lxf file, from an
;   uncompressed lef file or directly from memory. While
;   parsing, the data is validated against the LENEX 3 schema
;   using the LENEX3Validator PureBasic module. As result of
;   the parsing, an data instance, provided using LENEX3Data
;   PureBasic module, is created for accessing the file data.

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

XIncludeFile "Data.pb"
XIncludeFile "Validator.pb"

DeclareModule LENEX3Parser

;- >>> public constants declaration <<<

Enumeration Notices
  ; ----------------------------------------
  ; public     :: parser notice codes
  ; ----------------------------------------
  #NOTICE_ERROR_FILE_READ
  #NOTICE_ERROR_FILE_TYPE
  #NOTICE_ERROR_FILE_UNCOMPRESS
  #NOTICE_ERROR_XML_INVALID
  #NOTICE_ERROR_SCHEMA_ELEMENT_NOT_FOUND
  #NOTICE_ERROR_SCHEMA_ELEMENT_CONTEXT_MISMATCH
  #NOTICE_ERROR_SCHEMA_ELEMENT_COLLECT_MISMATCH
  #NOTICE_ERROR_SCHEMA_ELEMENT_REQUIRED_MISSING
  #NOTICE_WARNING_SCHEMA_ATTRIBUTE_CONTEXT_MISMATCH
  #NOTICE_WARNING_SCHEMA_ATTRIBUTE_ENUMERATION_MISMATCH
  #NOTICE_WARNING_SCHEMA_ATTRIBUTE_PATTERN_MISMATCH
  #NOTICE_WARNING_SCHEMA_ATTRIBUTE_REQUIRED_MISSING
EndEnumeration

;- >>> public structure declaration <<<

Structure NOTICE
  ; ----------------------------------------
  ; internal   :: parser notice
  ; ----------------------------------------
  iCode.i
  zPath.s
  zSubject.s
EndStructure

Structure PARSER
  ; ----------------------------------------
  ; public     :: parser structure
  ; ----------------------------------------
  iXML.i
  iSuccess.i
  *Data
  *Valid
  List Notices.NOTICE()
EndStructure

;- >>> public function declaration <<<

Declare.i examineNotices(*psParser.PARSER)
Declare.i nextNotice(*psParser.PARSER)
Declare.i getNoticeCode(*psParser.PARSER)
Declare.s getNoticePath(*psParser.PARSER)
Declare.s getNoticeSubject(*psParser.PARSER)
Declare.s getNoticeText(*psParser.PARSER)
Declare.i parseFile(pzPath.s)
Declare.i parseMemory(*pBuffer)
Declare.i getLENEX3Data(*psParser.PARSER)
Declare.i getSuccess(*psParser.PARSER)
Declare   free(*psParser.PARSER)

EndDeclareModule

Module LENEX3Parser

EnableExplicit

Procedure noticeHandler(*psParser.PARSER, piIR.i, piCode.i = -1, pzPath.s = "", pzSubject.s = "")
; ----------------------------------------
; internal   :: parser notice handling
; param      :: *psParser - parser structure
;               piIR      - notice handling mode
;                           0: insert new notice
;                           1: reset notice list
;               piCode    - (S: -1) notice code
;               pzPath    - (S: '') notice path
;               pzSubject - (S: '') notice subject
; returns    :: (nothing)
; ----------------------------------------

  If piIR = 0
    ; //
    ; new notice
    ; //
    AddElement(*psParser\Notices())
    *psParser\Notices()\iCode    = piCode
    *psParser\Notices()\zPath    = pzPath
    *psParser\Notices()\zSubject = pzSubject
  ElseIf piIR = 1
    ; //
    ; reset notice list
    ; //
    ClearList(*psParser\Notices())
  EndIf
    
EndProcedure

Procedure.i examineNotices(*psParser.PARSER)
; ----------------------------------------
; public     :: examine notices
; param      :: *psParser - parser structure
; returns    :: (i) #False - no notices in list
;                   #True  - notices found
; ----------------------------------------

  ResetList(*psParser\Notices())
  
  If ListSize(*psParser\Notices()) > 0
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False

EndProcedure

Procedure.i nextNotice(*psParser.PARSER)
; ----------------------------------------
; public     :: set current notice to the next one
; param      :: *psParser - parser structure
; returns    :: (i) 1 - next notice available
;                   0 - no more notices
; ----------------------------------------
  
  ProcedureReturn NextElement(*psParser\Notices())
  
EndProcedure

Procedure.i getNoticeCode(*psParser.PARSER)
; ----------------------------------------
; public     :: get the code of the current notice
; param      :: *psParser - parser structure
; returns    :: (i) notice code
; ----------------------------------------
  
  If ListIndex(*psParser\Notices()) > -1
    ProcedureReturn *psParser\Notices()\iCode
  Else
    ProcedureReturn -1
  EndIf
  
EndProcedure

Procedure.s getNoticePath(*psParser.PARSER)
; ----------------------------------------
; public     :: get the path of the current notice
; param      :: *psParser - parser structure
; returns    :: (s) notice path
; ----------------------------------------
  
  If ListIndex(*psParser\Notices()) > -1
    ProcedureReturn *psParser\Notices()\zPath
  Else
    ProcedureReturn ""
  EndIf
  
EndProcedure

Procedure.s getNoticeSubject(*psParser.PARSER)
; ----------------------------------------
; public     :: get the subject of the current notice
; param      :: *psParser - parser structure
; returns    :: (s) notice subject
; ----------------------------------------
  
  If ListIndex(*psParser\Notices()) > -1
    ProcedureReturn *psParser\Notices()\zSubject
  Else
    ProcedureReturn ""
  EndIf
  
EndProcedure

Procedure.s getNoticeText(*psParser.PARSER)
; ----------------------------------------
; public     :: get the text representation of the current notice
; param      :: *psParser - parser structure
; returns    :: (s) notice text
; ----------------------------------------
  Protected.s zText
; ----------------------------------------
  
  If ListIndex(*psParser\Notices()) = -1
    ProcedureReturn ""
  EndIf
  
  Select *psParser\Notices()\iCode
    Case #NOTICE_ERROR_FILE_READ
      zText = "error: file reading failed"
    Case #NOTICE_ERROR_FILE_TYPE
      zText = "error: invalid file type"
    Case #NOTICE_ERROR_FILE_UNCOMPRESS
      zText = "error: uncompressing failed"
    Case #NOTICE_ERROR_XML_INVALID
      zText = "error: invalid xml"
    Case #NOTICE_ERROR_SCHEMA_ELEMENT_NOT_FOUND
      zText = "error: element not found in schema"
    Case #NOTICE_ERROR_SCHEMA_ELEMENT_CONTEXT_MISMATCH
      zText = "error: element not allowed in this context"
    Case #NOTICE_ERROR_SCHEMA_ELEMENT_COLLECT_MISMATCH
      zText = "error: element does not match collector"
    Case #NOTICE_ERROR_SCHEMA_ELEMENT_REQUIRED_MISSING
      zText = "error: required element missing"
    Case #NOTICE_WARNING_SCHEMA_ATTRIBUTE_CONTEXT_MISMATCH
      zText = "warning: attribute not allowed in this context"
    Case #NOTICE_WARNING_SCHEMA_ATTRIBUTE_ENUMERATION_MISMATCH
      zText = "warning: attribute value does not match allowed values for this attribute"
    Case #NOTICE_WARNING_SCHEMA_ATTRIBUTE_PATTERN_MISMATCH
      zText = "warning: attribute value does not match the pattern for this attribute"
    Case #NOTICE_WARNING_SCHEMA_ATTRIBUTE_REQUIRED_MISSING
      zText = "warning: required attribute missing"
  EndSelect
  
  ProcedureReturn zText
  
EndProcedure

Procedure.i uncompressLXF(pzSourcePath.s)
; ----------------------------------------
; internal   :: uncompress the given .lxf file
; param      :: pzSourcePath - file name of source lxf data
; returns    :: (i) pointer to uncompressed data, 0 if error occurred
; ----------------------------------------
  Protected.i iPack,
              iSize
  Protected.s zRet
  Protected   *Buffer
; ----------------------------------------

  ; //
  ; init zip packer
  ; //
  UseZipPacker()
  
  ; //
  ; load packed file
  ; //
  iPack = OpenPack(#PB_Any, pzSourcePath, #PB_PackerPlugin_Zip)
  If Not iPack
    ProcedureReturn 0
  EndIf
  
  ; //
  ; check if archive contains file
  ; //
  ExaminePack(iPack)
  If Not NextPackEntry(iPack)
    ClosePack(iPack)
    ProcedureReturn 0
  EndIf
  
  ; //
  ; uncompress
  ; //
  iSize = PackEntrySize(iPack)
  *Buffer = AllocateMemory(iSize)
  If UncompressPackMemory(iPack, *Buffer, iSize) = 0
    FreeMemory(*Buffer)
    ClosePack(iPack)
    ProcedureReturn 0
  EndIf
  
  ClosePack(iPack)
  
  ProcedureReturn *Buffer
  
EndProcedure

Procedure.i parseXMLNodeAttributes(*psParser.PARSER, *pElem, *pNode)
; ----------------------------------------
; internal   :: parse the given xml node attributes
; param      :: *psParser - parser structure
;               *pElem    - data element
;               *pNode    - xml node
; returns    :: (i) 0 - error occurred
;                   1 - xml tree successfully parsed
; ----------------------------------------
  Protected.i iValid,
              iNotice
  Protected.s zElem,
              zAttrName,
              zAttrValue,
              zPath
  Protected NewList llzAttributes.s()
; ----------------------------------------
  
  zElem = GetXMLNodeName(*pNode)
  zPath = LENEX3Data::getPath(*psParser\Data, *pElem)
  
  ExamineXMLAttributes(*pNode)
  While NextXMLAttribute(*pNode)
    ; //
    ; attribute name and value
    ; //
    zAttrName  = XMLAttributeName(*pNode)
    zAttrValue = XMLAttributeValue(*pNode)
    
    ; //
    ; add non-empty attributes to attribute list
    ; //
    AddElement(llzAttributes())
    If zAttrValue <> ""
      llzAttributes() = zAttrName
    EndIf
    
    ; //
    ; run validation and apply default value if necessary
    ; //
    iValid = LENEX3Validator::validateAttribute(*psParser\Valid, zElem, zAttrName, zAttrValue, zPath)
    If iValid = LENEX3Validator::#INVALID
      LENEX3Validator::examineIssues()
      While LENEX3Validator::nextIssue()
        Select LENEX3Validator::getIssueCode()
          Case LENEX3Validator::#ATTRIBUTE_CONTEXT_MISMATCH
            iNotice = #NOTICE_WARNING_SCHEMA_ATTRIBUTE_CONTEXT_MISMATCH
          Case LENEX3Validator::#ATTRIBUTE_ENUMERATION_MISMATCH
            iNotice = #NOTICE_WARNING_SCHEMA_ATTRIBUTE_ENUMERATION_MISMATCH
          Case LENEX3Validator::#ATTRIBUTE_PATTERN_MISMATCH
            iNotice = #NOTICE_WARNING_SCHEMA_ATTRIBUTE_PATTERN_MISMATCH
          Case LENEX3Validator::#ATTRIBUTE_REQUIRED_MISSING
            iNotice = #NOTICE_WARNING_SCHEMA_ATTRIBUTE_REQUIRED_MISSING
        EndSelect
        noticeHandler(*psParser, 0, iNotice, zPath, LENEX3Validator::getIssueSubject())
      Wend
    ElseIf iValid = LENEX3Validator::#VALID_DEFAULT
      zAttrValue = LENEX3Validator::getAttributeDefault(*psParser\Valid, zElem, zAttrName)
    EndIf
    
    ; //
    ; add to data structure
    ; //
    LENEX3Data::setAttribute(*pElem, zAttrName, zAttrValue)
  Wend
  
  ; //
  ; validate if all required attributes are set
  ; //
  If LENEX3Validator::validateRequiredAttributes(*psParser\Valid, zElem, llzAttributes(), zPath) = LENEX3Validator::#INVALID
    LENEX3Validator::examineIssues()
    While LENEX3Validator::nextIssue()
      If LENEX3Validator::getIssueCode() = LENEX3Validator::#ATTRIBUTE_REQUIRED_MISSING
        noticeHandler(*psParser, 0, #NOTICE_WARNING_SCHEMA_ATTRIBUTE_REQUIRED_MISSING, zPath, LENEX3Validator::getIssueSubject())
      EndIf
    Wend
  EndIf
  
  ProcedureReturn 1

EndProcedure

Procedure parseXMLNode(*psParser.PARSER, *pParentElem, pzParentElem.s, *pNode)
; ----------------------------------------
; internal   :: parse the given xml node
; param      :: *psParser    - parser structure
;               *pParentElem - data element pointer
;               pzParentElem - parent element name
;               *pNode       - xml node
; returns    :: (nothing)
; ----------------------------------------
  Protected.i iValid
  Protected.s zName,
              zPath
  Protected *Elem,
            *SubNode
  Protected NewList llzSubElements.s()
; ----------------------------------------
  
  ; //
  ; name of current node
  ; //
  zName = GetXMLNodeName(*pNode)
  zPath = LENEX3Data::getPath(*psParser\Data, *pParentElem)
    
  ; //
  ; LENEX element is no sub element and doesn't need to be validated nor created in data
  ; //
  If zName = "LENEX"
    *Elem = *pParentElem
  Else
    ; //
    ; validate current node against schema
    ; //
    iValid = LENEX3Validator::validateSubElement(*psParser\Valid, pzParentElem, zName, zPath)
    If iValid = LENEX3Validator::#INVALID
      LENEX3Validator::examineIssues()
      While LENEX3Validator::nextIssue()
        Select LENEX3Validator::getIssueCode()
          Case LENEX3Validator::#ELEMENT_COLLECT_MISMATCH,
               LENEX3Validator::#ELEMENT_COLLECT_NO_ELEMENT
            noticeHandler(*psParser, 0, #NOTICE_ERROR_SCHEMA_ELEMENT_COLLECT_MISMATCH, zPath, LENEX3Validator::getIssueSubject())
          Case LENEX3Validator::#ELEMENT_NOT_IN_SCHEMA
            noticeHandler(*psParser, 0, #NOTICE_ERROR_SCHEMA_ELEMENT_NOT_FOUND, zPath, LENEX3Validator::getIssueSubject())        
          Case LENEX3Validator::#SUBELEMENT_NOT_IN_SCHEMA
            noticeHandler(*psParser, 0, #NOTICE_ERROR_SCHEMA_ELEMENT_NOT_FOUND, zPath, LENEX3Validator::getIssueSubject())
          Case LENEX3Validator::#SUBELEMENT_CONTEXT_MISMATCH
            noticeHandler(*psParser, 0, #NOTICE_ERROR_SCHEMA_ELEMENT_CONTEXT_MISMATCH, zPath, LENEX3Validator::getIssueSubject())
        EndSelect
      Wend
      ProcedureReturn
    EndIf
  
    ; //
    ; create data element
    ; //
    *Elem = LENEX3Data::createSubElement(*pParentElem, zName)
  EndIf

  ; //
  ; attributes
  ; //
  parseXMLNodeAttributes(*psParser, *Elem, *pNode)
  
  ; //
  ; sub elements
  ; //
  *SubNode = ChildXMLNode(*pNode)
  While *SubNode
    AddElement(llzSubElements())
    llzSubElements() = GetXMLNodeName(*SubNode)
    
    parseXMLNode(*psParser, *Elem, zName, *SubNode)
    *SubNode = NextXMLNode(*SubNode)
  Wend
  
  ; //
  ; validate if all required sub elements are set
  ; //
  If LENEX3Validator::validateRequiredSubElements(*psParser\Valid, zName, llzSubElements(), zPath) = LENEX3Validator::#INVALID
    LENEX3Validator::examineIssues()
    While LENEX3Validator::nextIssue()
      If LENEX3Validator::getIssueCode() = LENEX3Validator::#SUBELEMENT_REQUIRED_MISSING
        noticeHandler(*psParser, 0, #NOTICE_ERROR_SCHEMA_ELEMENT_REQUIRED_MISSING, zPath, LENEX3Validator::getIssueSubject())
      EndIf
    Wend
  EndIf
    
EndProcedure

Procedure.i parseXMLTree(*psParser.PARSER)
; ----------------------------------------
; internal   :: start parsing the xml tree
; param      :: *psParser - parser structure
; returns    :: (i) 0 - error occurred
;                   1 - xml tree successfully parsed
; ----------------------------------------
  Protected *MainNode,
            *SubNode,
            *RootElem
; ----------------------------------------
  
  ; //
  ; main xml node
  ; //
  *MainNode = MainXMLNode(*psParser\iXML)
  If Not *MainNode
    noticeHandler(0, #NOTICE_ERROR_XML_INVALID)
    ProcedureReturn 0
  EndIf
  
  ; //
  ; root data structure element
  ; //
  *RootElem = LENEX3Data::getRootElement(*psParser\Data)
  
  ; //
  ; examine sub nodes
  ; //
  parseXMLNode(*psParser, *RootElem, "LENEX", *MainNode)
  
  ProcedureReturn 1

EndProcedure

Procedure.i startParsing(*psParser.PARSER, *pBuffer)
; ----------------------------------------
; internal   :: start parsing process
; param      :: *psParser - parser structure
;               *pBuffer  - pointer to data to parse
; returns    :: (i) 1 for success, 0 if error occurred
; ----------------------------------------
  Protected.i iXML
; ----------------------------------------
  
  ; //
  ; load xml
  ; //
  iXML = CatchXML(#PB_Any, *pBuffer, MemorySize(*pBuffer))
  If Not IsXML(iXML) Or XMLStatus(iXML) <> #PB_XML_Success
    noticeHandler(*psParser, 0, #NOTICE_ERROR_XML_INVALID, Str(XMLErrorLine(iXML)), Str(XMLErrorPosition(iXML)))
    FreeXML(iXML)
    ProcedureReturn 0
  EndIf
  
  ; //
  ; attach xml handle
  ; //
  *psParser\iXML = iXML
  
  ; //
  ; create data
  ; //
  *psParser\Data = LENEX3Data::create("3.0")

  ; //
  ; create validator
  ; //
  *psParser\Valid = LENEX3Validator::create()
  
  ; //
  ; parse xml tree
  ; //
  ProcedureReturn parseXMLTree(*psParser)
  
EndProcedure

Procedure.i parseFile(pzPath.s)
; ----------------------------------------
; public     :: parse from file
; param      :: pzPath - file name of source
; returns    :: (i) pointer to parser structure
; ----------------------------------------
  Protected.i iFile,
              iLen
  Protected.s zExt
  Protected *sParser.PARSER
  Protected *Buffer
; ----------------------------------------

  ; //
  ; initialize parser structure
  ; //
  *sParser = AllocateStructure(PARSER)
  
  ; //
  ; load file
  ; //
  zExt = GetExtensionPart(pzPath)
  If zExt = "lxf"
    ; //
    ; compressed
    ; //
    *Buffer = uncompressLXF(pzPath)
    If *Buffer = 0
      noticeHandler(*sParser, 0, #NOTICE_ERROR_FILE_UNCOMPRESS, "", pzPath)
      *sParser\iSuccess = #False
      ProcedureReturn *sParser
    EndIf
  ElseIf zExt = "lef"
    ; //
    ; not compressed
    ; //
    iFile = ReadFile(#PB_Any, pzPath)
    If Not IsFile(iFile)
      noticeHandler(*sParser, 0, #NOTICE_ERROR_FILE_READ, "", pzPath)
      *sParser\iSuccess = #False
      ProcedureReturn *sParser
    EndIf
    
    iLen = Lof(iFile)
    *Buffer = AllocateMemory(iLen)
    If Not ReadData(iFile, *Buffer, iLen)
      CloseFile(iFile)
      *sParser\iSuccess = #False
      noticeHandler(*sParser, 0, #NOTICE_ERROR_FILE_READ, "", pzPath)
      ProcedureReturn *sParser
    EndIf
    CloseFile(iFile)
  Else
    ; //
    ; invalid file extension
    ; //
    noticeHandler(*sParser, 0, #NOTICE_ERROR_FILE_TYPE, "", pzPath)
    *sParser\iSuccess = #False
    ProcedureReturn *sParser
  EndIf
  
  ; //
  ; parse data in memory
  ; //
  *sParser\iSuccess = startParsing(*sParser, *Buffer)
  FreeMemory(*Buffer)
  
  ProcedureReturn *sParser
  
EndProcedure

Procedure.i parseMemory(*pBuffer)
; ----------------------------------------
; public     :: parse from memory
; param      :: *pBuffer - pointer to data to parse
; returns    :: (i) pointer to parser structure, 0 if error occurred
; ----------------------------------------
  Protected *sParser.PARSER
; ----------------------------------------

  ; //
  ; initialize parser structure
  ; //
  *sParser = AllocateStructure(PARSER)
  
  ; //
  ; parse data in memory
  ; //
  *sParser\iSuccess = startParsing(*sParser, *pBuffer)
  
  ProcedureReturn *sParser
  
EndProcedure

Procedure.i getLENEX3Data(*psParser.PARSER)
; ----------------------------------------
; public     :: get LENEX3Data structure pointer for further use
; param      :: *psParser - parser structure
; returns    :: (i) parser to LENEX3Data structure
; ----------------------------------------

  ProcedureReturn *psParser\Data

EndProcedure

Procedure.i getSuccess(*psParser.PARSER)
; ----------------------------------------
; public     :: get success flag from parser
; param      :: *psParser - parser structure
; returns    :: (i) #True if parsing was successfull, #False otherwise
; ----------------------------------------

  ProcedureReturn *psParser\iSuccess

EndProcedure

Procedure free(*psParser.PARSER)
; ----------------------------------------
; public     :: free parser resources
; param      :: *psParser - parser structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; free validator
  ; //
  LENEX3Validator::free(*psParser\Valid)
  
  ; //
  ; free parser structure
  ; //
  FreeStructure(*psParser)
  
EndProcedure

EndModule