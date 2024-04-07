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

Structure PARSER
  ; ----------------------------------------
  ; public     :: parser structure
  ; ----------------------------------------
  iXML.i
  *Data
  *Valid
EndStructure

;- >>> public function declaration <<<

Declare.i examineNotices()
Declare.i nextNotice()
Declare.i getNoticeCode()
Declare.s getNoticePath()
Declare.s getNoticeSubject()
Declare.i parseFile(pzPath.s)
Declare.i parseMemory(*pBuffer)
Declare.i getLENEX3Data(*psParser.PARSER)
Declare   free(*psParser.PARSER)

EndDeclareModule

Module LENEX3Parser

EnableExplicit

Structure NOTICE
  ; ----------------------------------------
  ; internal   :: parser notice
  ; ----------------------------------------
  iCode.i
  zPath.s
  zSubject.s
EndStructure

Structure NOTICELIST
  ; ----------------------------------------
  ; internal   :: parser notice list
  ; ----------------------------------------
  List Notices.NOTICE()
EndStructure

Procedure.i noticeHandler(piIGRF.i, piCode.i = -1, pzPath.s = "", pzSubject.s = "")
; ----------------------------------------
; internal   :: parser notice handling
; param      :: piIGRF    -  notice handling mode
;                            0: insert new notice
;                            1: get notice list
;                            2: reset notice list
;                            3: free notice list
;               piCode    - (S: -1) notice code
;               pzPath    - (S: '') notice path
;               pzSubject - (S: '') notice subject
; returns    :: (i) pointer to notice list if piIGR = 1, else 0
; ----------------------------------------
  Static *sList.NOTICELIST
; ----------------------------------------

  If piIGRF = 0
    ; //
    ; new notice
    ; //
    AddElement(*sList\Notices())
    *sList\Notices()\iCode    = piCode
    *sList\Notices()\zPath    = pzPath
    *sList\Notices()\zSubject = pzSubject
  ElseIf piIGRF = 1
    ; //
    ; get notice list
    ; //
    ProcedureReturn *sList
  ElseIf piIGRF = 2
    ; //
    ; reset notice list
    ; //
    FreeStructure(*sList)
    *sList = AllocateStructure(NOTICELIST)
  ElseIf piIGRF = 3
    ; //
    ; free notice list
    ; //
    FreeStructure(*sList)
  EndIf
  
  ProcedureReturn 0
  
EndProcedure

Procedure.i examineNotices()
; ----------------------------------------
; public     :: examine notices
; param      :: (none)
; returns    :: (i) #False - no notices in list
;                   #True - notices found
; ----------------------------------------
  Protected *sList.NOTICELIST
; ----------------------------------------

  *sList = noticeHandler(1)
  ResetList(*sList\Notices())
  
  If ListSize(*sList\Notices()) > 0
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False

EndProcedure

Procedure.i nextNotice()
; ----------------------------------------
; public     :: set current notice to the next one
; param      :: (none)
; returns    :: (i) 1 - next notice available
;                   0 - no more notices
; ----------------------------------------
  Protected *sList.NOTICELIST
; ----------------------------------------

  *sList = noticeHandler(1)
  
  ProcedureReturn NextElement(*sList\Notices())
  
EndProcedure

Procedure.i getNoticeCode()
; ----------------------------------------
; public     :: get the code of the current notice
; param      :: (none)
; returns    :: (i) notice code
; ----------------------------------------
  Protected *sList.NOTICELIST
; ----------------------------------------

  *sList = noticeHandler(1)
  
  If ListIndex(*sList\Notices())
    ProcedureReturn *sList\Notices()\iCode
  Else
    ProcedureReturn -1
  EndIf
  
EndProcedure

Procedure.s getNoticePath()
; ----------------------------------------
; public     :: get the path of the current notice
; param      :: (none)
; returns    :: (s) notice path
; ----------------------------------------
  Protected *sList.NOTICELIST
; ----------------------------------------

  *sList = noticeHandler(1)
  
  If ListIndex(*sList\Notices())
    ProcedureReturn *sList\Notices()\zPath
  Else
    ProcedureReturn ""
  EndIf
  
EndProcedure

Procedure.s getNoticeSubject()
; ----------------------------------------
; public     :: get the subject of the current notice
; param      :: (none)
; returns    :: (s) notice subject
; ----------------------------------------
  Protected *sList.NOTICELIST
; ----------------------------------------

  *sList = noticeHandler(1)
  
  If ListIndex(*sList\Notices())
    ProcedureReturn *sList\Notices()\zSubject
  Else
    ProcedureReturn ""
  EndIf
  
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
        noticeHandler(0, iNotice, zPath, zAttrName)
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
        noticeHandler(0, #NOTICE_WARNING_SCHEMA_ATTRIBUTE_REQUIRED_MISSING, zPath, LENEX3Validator::getIssueSubject())
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
  ; validate current node against schema
  ; //
  iValid = LENEX3Validator::validateSubElement(*psParser\Valid, pzParentElem, zName, zPath)
  If iValid = LENEX3Validator::#INVALID
    LENEX3Validator::examineIssues()
    While LENEX3Validator::nextIssue()
      Select LENEX3Validator::getIssueCode()
        Case LENEX3Validator::#ELEMENT_COLLECT_MISMATCH,
             LENEX3Validator::#ELEMENT_COLLECT_NO_ELEMENT
          noticeHandler(0, #NOTICE_ERROR_SCHEMA_ELEMENT_COLLECT_MISMATCH, zPath, zName)
        Case LENEX3Validator::#ELEMENT_NOT_IN_SCHEMA
          noticeHandler(0, #NOTICE_ERROR_SCHEMA_ELEMENT_NOT_FOUND, zPath, pzParentElem)        
        Case LENEX3Validator::#SUBELEMENT_NOT_IN_SCHEMA
          noticeHandler(0, #NOTICE_ERROR_SCHEMA_ELEMENT_NOT_FOUND, zPath, zName)
        Case LENEX3Validator::#SUBELEMENT_CONTEXT_MISMATCH
          noticeHandler(0, #NOTICE_ERROR_SCHEMA_ELEMENT_CONTEXT_MISMATCH, zPath, zName)
      EndSelect
    Wend
    ProcedureReturn
  EndIf
  
  ; //
  ; create data element
  ; //
  *Elem = LENEX3Data::createSubElement(*pParentElem, zName)
  
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
        noticeHandler(0, #NOTICE_ERROR_SCHEMA_ELEMENT_REQUIRED_MISSING, zPath, LENEX3Validator::getIssueSubject())
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

EndProcedure

Procedure.i startParsing(*pBuffer)
; ----------------------------------------
; internal   :: start parsing process
; param      :: *pBuffer - pointer to data to parse
; returns    :: (i) pointer to parser structure, 0 if error occurred
; ----------------------------------------
  Protected.i iXML
  Protected *sParser.PARSER
; ----------------------------------------
  
  ; //
  ; load xml
  ; //
  iXML = CatchXML(#PB_Any, *pBuffer, MemorySize(*pBuffer))
  If Not IsXML(iXML) Or XMLStatus(iXML) <> #PB_XML_Success
    noticeHandler(0, #NOTICE_ERROR_XML_INVALID, Str(XMLErrorLine(iXML)), Str(XMLErrorPosition(iXML)))
    FreeXML(iXML)
    ProcedureReturn 0
  EndIf
  
  ; //
  ; initialize parser structure
  ; //
  *sParser = AllocateStructure(PARSER)
  
  ; //
  ; attach xml handle
  ; //
  *sParser\iXML = iXML
  
  ; //
  ; create data
  ; //
  *sParser\Data = LENEX3Data::create("3.0")

  ; //
  ; create validator
  ; //
  *sParser\Valid = LENEX3Validator::create()
  
  ; //
  ; parse xml tree
  ; //
  parseXMLTree(*sParser)
  
  ProcedureReturn *sParser

EndProcedure

Procedure.i parseFile(pzPath.s)
; ----------------------------------------
; public     :: parse from file
; param      :: pzPath - file name of source
; returns    :: (i) pointer to parser structure, 0 if error occurred
; ----------------------------------------
  Protected.i iFile,
              iLen,
              iResult
  Protected.s zExt
  Protected *Buffer
; ----------------------------------------
  
  ; //
  ; init notice handler
  ; //
  noticeHandler(2)
  
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
      noticeHandler(0, #NOTICE_ERROR_FILE_UNCOMPRESS, "", pzPath)
      ProcedureReturn 0
    EndIf
  ElseIf zExt = "lef"
    ; //
    ; not compressed
    ; //
    iFile = ReadFile(#PB_Any, pzPath)
    If Not IsFile(iFile)
      noticeHandler(0, #NOTICE_ERROR_FILE_READ, "", pzPath)
      ProcedureReturn 0
    EndIf
    
    iLen = Lof(iFile)
    *Buffer = AllocateMemory(iLen)
    If Not ReadData(iFile, *Buffer, iLen)
      CloseFile(iFile)
      noticeHandler(0, #NOTICE_ERROR_FILE_READ, "", pzPath)
      ProcedureReturn 0
    EndIf
    CloseFile(iFile)
  Else
    ; //
    ; invalid file extension
    ; //
    noticeHandler(0, #NOTICE_ERROR_FILE_TYPE, "", pzPath)
    ProcedureReturn 0
  EndIf
  
  ; //
  ; parse data in memory
  ; //
  iResult = startParsing(*Buffer)
  FreeMemory(*Buffer)
  
  ProcedureReturn iResult
  
EndProcedure

Procedure.i parseMemory(*pBuffer)
; ----------------------------------------
; public     :: parse from memory
; param      :: *pBuffer - pointer to data to parse
; returns    :: (i) pointer to parser structure, 0 if error occurred
; ----------------------------------------
  Protected.i iResult
; ----------------------------------------
  
  ; //
  ; init notice handler
  ; //
  noticeHandler(2)
  
  ; //
  ; parse data in memory
  ; //
  iResult = startParsing(*pBuffer)
  
  ProcedureReturn iResult
  
EndProcedure

Procedure.i getLENEX3Data(*psParser.PARSER)
; ----------------------------------------
; public     :: get LENEX3Data structure pointer for further use
; param      :: *psParser - parser structure
; returns    :: (i) parser to LENEX3Data structure
; ----------------------------------------

  ProcedureReturn *psParser\Data

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
  
  ; //
  ; free notice list
  ; //
  noticeHandler(3)
  
EndProcedure

EndModule