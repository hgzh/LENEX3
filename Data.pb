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
Declare.i nextOf(*pPrevElem)
Declare.s getAttribute(*pNode, pzAttribute.s)
Declare   setAttribute(*pNode, pzAttribute.s, pzValue.s)
Declare.s getVersion(*psData.LENEX)
Declare   setVersion(*psData.LENEX, pzVersion.s)
Declare.i getConstructor(*psData.LENEX)
Declare.i createConstructor(*psData.LENEX)
Declare.i getFirstMeet(*psData.LENEX)
Declare.i getMeetByName(*psData.LENEX, pzName.s)
Declare.i createMeet(*psData.LENEX)
Declare.i getFirstRecordlist(*psData.LENEX)
Declare.i getRecordlistByName(*psData.LENEX, pzName.s)
Declare.i createRecordlist(*psData.LENEX)
Declare.i getFirstTimestandardlist(*psData.LENEX)
Declare.i getTimestandardlistByID(*psData.LENEX, piID.i)
Declare.i getTimestandardlistByName(*psData.LENEX, pzName.s)
Declare.i createTimestandardlist(*psData.LENEX)
Declare.i getFirstTimestandard(*pTimestandardlist)
Declare.i createTimestandard(*pTimestandardlist)

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

;- >>> basic elements <<<

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

Procedure.i getCreateSubElement(*pElem, pzName.s)
; ----------------------------------------
; internal   :: tries to get the sub element, if not existing, creates it
; param      :: *pElem - parent element
;               pzName - element name
; returns    :: (i) pointer to element
; ----------------------------------------
  Protected *SubElem
; ----------------------------------------

  *SubElem = XMLNodeFromPath(*pElem, pzName)
  If Not *SubElem
    *SubElem = createSubElement(*pElem, pzName)
  EndIf
  
  ProcedureReturn *SubElem
  
EndProcedure

Procedure.i nextOf(*pPrevElem)
; ----------------------------------------
; public     :: get the next sub element in the collection
; param      :: *psData    - data structure
;               *pPrevElem - previous data element node
; returns    :: (i) pointer to next data element node
; ----------------------------------------

  ProcedureReturn NextXMLNode(*pPrevElem)

EndProcedure

;- >>> attributes <<<

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

;- >>> basic lenex <<<

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

  ProcedureReturn XMLNodeFromPath(*psData\Root, "/LENEX/CONSTRUCTOR")

EndProcedure

Procedure.i createConstructor(*psData.LENEX)
; ----------------------------------------
; public     :: create CONSTRUCTOR element
; param      :: *psData - data structure
; returns    :: (i) pointer to new CONSTRUCTOR node
; ----------------------------------------

  ProcedureReturn createSubElement(*psData\Root, "CONSTRUCTOR")

EndProcedure

;- >>> meets <<<

Procedure.i getFirstMeet(*psData.LENEX)
; ----------------------------------------
; public     :: get the first meet in the MEETS collection
; param      :: *psData - data structure
; returns    :: (i) pointer to first MEET node
; ----------------------------------------

  ProcedureReturn XMLNodeFromPath(*psData\Root, "/LENEX/MEETS/MEET[1]")

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
    *Meet = nextOf(*Meet)
  Wend

EndProcedure

Procedure.i createMeet(*psData.LENEX)
; ----------------------------------------
; public     :: create MEET element
; param      :: *psData - data structure
; returns    :: (i) pointer to new MEET node
; ----------------------------------------
  
  ProcedureReturn createSubElement(getCreateSubElement(*psData\Root, "MEETS"), "MEET")

EndProcedure

;- >>> records <<<

Procedure.i getFirstRecordlist(*psData.LENEX)
; ----------------------------------------
; public     :: get the first meet in the RECORDLISTS collection
; param      :: *psData - data structure
; returns    :: (i) pointer to first RECORDLIST node
; ----------------------------------------

  ProcedureReturn XMLNodeFromPath(*psData\Root, "/LENEX/RECORDLISTS/RECORDLIST[1]")

EndProcedure

Procedure.i getRecordlistByName(*psData.LENEX, pzName.s)
; ----------------------------------------
; public     :: get the recordlist with the given name
; param      :: *psData - data structure
;               pzName  - recordlist name
; returns    :: (i) pointer to RECORDLIST node
; ----------------------------------------
  Protected *Recordlist
; ----------------------------------------

  *Recordlist = getFirstRecordlist(*psData)
  While *Recordlist
    If LCase(getAttribute(*Recordlist, "name")) = LCase(pzName)
      ProcedureReturn *Recordlist
    EndIf
    *Recordlist = nextOf(*Recordlist)
  Wend

EndProcedure

Procedure.i createRecordlist(*psData.LENEX)
; ----------------------------------------
; public     :: create RECORDLIST element
; param      :: *psData - data structure
; returns    :: (i) pointer to new RECORDLIST node
; ----------------------------------------
  
  ProcedureReturn createSubElement(getCreateSubElement(*psData\Root, "RECORDLISTS"), "RECORDLIST")

EndProcedure

;- >>> timestandards <<<

Procedure.i getFirstTimestandardlist(*psData.LENEX)
; ----------------------------------------
; public     :: get the first meet in the TIMESTANDARDLISTS collection
; param      :: *psData - data structure
; returns    :: (i) pointer to first TIMESTANDARDLIST node
; ----------------------------------------

  ProcedureReturn XMLNodeFromPath(*psData\Root, "/LENEX/TIMESTANDARDLISTS/TIMESTANDARDLIST[1]")

EndProcedure

Procedure.i getTimestandardlistByID(*psData.LENEX, piID.i)
; ----------------------------------------
; public     :: get the timestandardlist with the given ID
; param      :: *psData - data structure
;               piID    - timestandardlist identifier
; returns    :: (i) pointer to TIMESTANDARDLIST node
; ----------------------------------------
  Protected *Timestandardlist
; ----------------------------------------

  *Timestandardlist = getFirstTimestandardlist(*psData)
  While *Timestandardlist
    If Val(getAttribute(*Timestandardlist, "timestandardlistid")) = piID
      ProcedureReturn *Timestandardlist
    EndIf
    *Timestandardlist = nextOf(*Timestandardlist)
  Wend

EndProcedure

Procedure.i getTimestandardlistByName(*psData.LENEX, pzName.s)
; ----------------------------------------
; public     :: get the timestandardlist with the given name
; param      :: *psData - data structure
;               pzName  - timestandardlist name
; returns    :: (i) pointer to TIMESTANDARDLIST node
; ----------------------------------------
  Protected *Timestandardlist
; ----------------------------------------

  *Timestandardlist = getFirstTimestandardlist(*psData)
  While *Timestandardlist
    If LCase(getAttribute(*Timestandardlist, "name")) = LCase(pzName)
      ProcedureReturn *Timestandardlist
    EndIf
    *Timestandardlist = nextOf(*Timestandardlist)
  Wend

EndProcedure

Procedure.i createTimestandardlist(*psData.LENEX)
; ----------------------------------------
; public     :: create TIMESTANDARDLIST element
; param      :: *psData - data structure
; returns    :: (i) pointer to new TIMESTANDARDLIST node
; ----------------------------------------
  
  ProcedureReturn createSubElement(getCreateSubElement(*psData\Root, "TIMESTANDARDLISTS"), "TIMESTANDARDLIST")

EndProcedure

Procedure.i getFirstTimestandard(*pTimestandardlist)
; ----------------------------------------
; public     :: get the first meet in the TIMESTANDARDS collection
; param      :: *psTimestandardlist - timestandardlist pointer
; returns    :: (i) pointer to first TIMESTANDARD node
; ----------------------------------------

  ProcedureReturn XMLNodeFromPath(*pTimestandardlist, "TIMESTANDARDS/TIMESTANDARD[1]")

EndProcedure

Procedure.i createTimestandard(*pTimestandardlist)
; ----------------------------------------
; public     :: create TIMESTANDARD element
; param      :: *psData - data structure
; returns    :: (i) pointer to new TIMESTANDARD node
; ----------------------------------------
  
  ProcedureReturn createSubElement(getCreateSubElement(*pTimestandardlist, "TIMESTANDARDS"), "TIMESTANDARD")

EndProcedure

EndModule