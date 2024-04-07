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
Declare   addAttribute(*pElem, pzName.s, pzValue.s)

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

Procedure addAttribute(*pElem, pzName.s, pzValue.s)
; ----------------------------------------
; public     :: add attribute to given element
; param      :: *pElem  - current element
;               pzName  - attribute name
;               pzValue - attribute value
; returns    :: (nothing)
; ----------------------------------------

  SetXMLAttribute(*pElem, LCase(pzName), pzValue)

EndProcedure

EndModule