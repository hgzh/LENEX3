; ###########################################################
; ################# LENEX 3 DATA PB MODULE ##################
; ###########################################################

;   written by hgzh, 2024

;   This module provides an interface to LENEX 3 data parsed
;   using the LENEX3Parser PureBasic module.

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

DeclareModule LENEX3Data

;- >>> public structure declaration <<<

Structure LENEX
  ; ----------------------------------------
  ; public     :: data structure
  ; ----------------------------------------
  iXML.i
  *Root
EndStructure

;- >>> public function declaration <<<

Declare.i create(pzVersion.s)
Declare   free(*psData.LENEX)
Declare.i getRootElement(*psData.LENEX)
Declare.s getPath(*psData.LENEX, *pElem)
Declare.i createSubElement(*pElem, pzName.s)
Declare.s getAttribute(*pNode, pzAttribute.s)
Declare   setAttribute(*pNode, pzAttribute.s, pzValue.s)
Declare.s getVersion(*psData.LENEX)
Declare   setVersion(*psData.LENEX, pzVersion.s)
Declare.i getConstructor(*psData.LENEX)
Declare.i createConstructor(*psData.LENEX)
Declare.i getFirstMeet(*psData.LENEX)
Declare.i nextMeet(*pPrevMeet)
Declare.i getMeetByName(*psData.LENEX, pzName.s)
Declare.i createMeet(*psData.LENEX)

EndDeclareModule

Module LENEX3Data

EnableExplicit

Procedure.i create(pzVersion.s)
; ----------------------------------------
; public     :: create new datastructure
; param      :: pzVersion - lenex version
; returns    :: (i) pointer to data structure
; ----------------------------------------
  Protected *sData.LENEX
; ----------------------------------------
  
  ; //
  ; create data structure
  ; //
  *sData = AllocateStructure(LENEX)
  
  ; //
  ; create xml
  ; //
  *sData\iXML = CreateXML(#PB_Any)
  
  ; //
  ; create root element
  ; //
  *sData\Root = CreateXMLNode(RootXMLNode(*sData\iXML), "LENEX")
  
  ; //
  ; set version
  ; //
  SetXMLAttribute(*sData\Root, "version", pzVersion)
  
  ProcedureReturn *sData

EndProcedure

Procedure free(*psData.LENEX)
; ----------------------------------------
; public     :: free data structure
; param      :: *psData - data structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; free xml
  ; //
  FreeXML(*psData\iXML)
  
  ; //
  ; free data structure
  ; //
  FreeStructure(*psData)

EndProcedure

Procedure.i getRootElement(*psData.LENEX)
; ----------------------------------------
; public     :: get the root element of the data structure
; param      :: *psData - data structure
; returns    :: (i) pointer to the root element
; ----------------------------------------

  ProcedureReturn @*psData\Root

EndProcedure

Procedure.s getPath(*psData.LENEX, *pElem)
; ----------------------------------------
; public     :: get the path from the root element to the target element
; param      :: *psData - data structure
;               *psElem - target element
; returns    :: (s) path string
; ----------------------------------------

  ProcedureReturn XMLNodePath(*pElem)
  
EndProcedure

Procedure.i createSubElement(*pElem, pzName.s)
; ----------------------------------------
; public     :: add sub element to given element
; param      :: *pElem - parent element
;               pzName - element name
; returns    :: (i) pointer to created element
; ----------------------------------------
  
  ProcedureReturn CreateXMLNode(*pElem, UCase(pzName))
  
EndProcedure

Procedure.s getAttribute(*pNode, pzAttribute.s)
; ----------------------------------------
; public     :: get the attribute of the given node
; param      :: *pNode      - data node
;               pzAttribute - attribute name
; returns    :: (s) attribute value
; ----------------------------------------

  ProcedureReturn GetXMLAttribute(*pNode, pzAttribute)

EndProcedure

Procedure setAttribute(*pNode, pzAttribute.s, pzValue.s)
; ----------------------------------------
; public     :: set the attribute of the given node
; param      :: *pNode      - data node
;               pzAttribute - attribute name
;               pzValue     - attribute value
; returns    :: (nothing)
; ----------------------------------------

  SetXMLAttribute(*pNode, LCase(pzAttribute), pzValue)

EndProcedure

Procedure.s getVersion(*psData.LENEX)
; ----------------------------------------
; public     :: get the LENEX version
; param      :: *psData - data structure
; returns    :: (s) LENEX version
; ----------------------------------------

  ProcedureReturn GetXMLAttribute(*psData\Root, "version")

EndProcedure

Procedure setVersion(*psData.LENEX, pzVersion.s)
; ----------------------------------------
; public     :: set the LENEX version
; param      :: *psData   - data structure
;               pzVersion - version value
; returns    :: (nothing)
; ----------------------------------------

  SetXMLAttribute(*psData\Root, "version", pzVersion)

EndProcedure

Procedure.i getConstructor(*psData.LENEX)
; ----------------------------------------
; public     :: get the CONSTRUCTOR node
; param      :: *psData - data structure
; returns    :: (i) pointer to CONSTRUCTOR node
; ----------------------------------------

  ProcedureReturn XMLNodeFromPath(*psData\Root, "LENEX/CONSTRUCTOR")

EndProcedure

Procedure.i createConstructor(*psData.LENEX)
; ----------------------------------------
; public     :: create CONSTRUCTOR element
; param      :: *psData - data structure
; returns    :: (i) pointer to new CONSTRUCTOR node
; ----------------------------------------

  ProcedureReturn createSubElement(*psData\Root, "CONSTRUCTOR")

EndProcedure

Procedure.i getFirstMeet(*psData.LENEX)
; ----------------------------------------
; public     :: get the first meet in the MEETS connection
; param      :: *psData - data structure
; returns    :: (i) pointer to first MEET node
; ----------------------------------------

  ProcedureReturn XMLNodeFromPath(*psData\Root, "LENEX/MEETS/MEET[1]")

EndProcedure

Procedure.i nextMeet(*pPrevMeet)
; ----------------------------------------
; public     :: get the next meet from the MEETS collection
; param      :: *psData    - data structure
;               *pPrevMeet - previous meet node
; returns    :: (i) pointer to next MEET node
; ----------------------------------------

  ProcedureReturn NextXMLNode(*pPrevMeet)

EndProcedure

Procedure.i getMeetByName(*psData.LENEX, pzName.s)
; ----------------------------------------
; public     :: get the meet with the given name
; param      :: *psData - data structure
;               pzName  - meet name
; returns    :: (i) pointer to MEET node
; ----------------------------------------
  Protected *Meet
; ----------------------------------------

  *Meet = getFirstMeet(*psData)
  While *Meet
    If LCase(getAttribute(*Meet, "name")) = LCase(pzName)
      ProcedureReturn *Meet
    EndIf
    *Meet = nextMeet(*Meet)
  Wend

EndProcedure

Procedure.i createMeet(*psData.LENEX)
; ----------------------------------------
; public     :: create MEET element
; param      :: *psData - data structure
; returns    :: (i) pointer to new MEET node
; ----------------------------------------
  Protected *Meets
; ----------------------------------------
  
  *Meets = XMLNodeFromPath(*psData\Root, "LENEX/MEETS")
  If Not *Meets
    ProcedureReturn 0
  EndIf
  
  ProcedureReturn createSubElement(*Meets, "MEET")

EndProcedure

EndModule