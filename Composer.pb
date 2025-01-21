; ###########################################################
; ############### LENEX 3 COMPOSER PB MODULE ################
; ###########################################################

;   written by hgzh, 2024-2025

;   This module provides a way to compose LENEX 3 data back
;   to a file or a string.

; ###########################################################
;                          LICENSING
; Copyright (c) 2024-2025 hgzh

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

DeclareModule LENEX3Composer

;- >>> public structure declaration <<<

Structure COMPOSER
  ; ----------------------------------------
  ; public     :: composer structure
  ; ----------------------------------------
  iXML.i
  iFormat.i
EndStructure

;- >>> public function declaration <<<

Declare.i create()
Declare.i free(*psComposer.COMPOSER)
Declare.i useLENEX3Data(*psComposer.COMPOSER, *pData)
Declare   enableFormattedOutput(*psComposer.COMPOSER)
Declare   disableFormattedOutput(*psComposer.COMPOSER)
Declare.i saveLEF(*psComposer.COMPOSER, pzPath.s)
Declare.i saveLXF(*psComposer.COMPOSER, pzPath.s)
Declare.s getString(*psComposer.COMPOSER)

EndDeclareModule

Module LENEX3Composer

EnableExplicit

Procedure.i create()
; ----------------------------------------
; public     :: create new composer
; param      :: (none)
; returns    :: (i) pointer to composer structure
; ----------------------------------------
  Protected *sComposer.COMPOSER
; ----------------------------------------
  
  ; //
  ; create data structure
  ; //
  *sComposer = AllocateStructure(COMPOSER)
  
  ProcedureReturn *sComposer

EndProcedure

Procedure free(*psComposer.COMPOSER)
; ----------------------------------------
; public     :: free composer structure
; param      :: *psComposer - composer structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; free composer structure
  ; //
  FreeStructure(*psComposer)

EndProcedure

Procedure useLENEX3Data(*psComposer.COMPOSER, *pData)
; ----------------------------------------
; public     :: use the given data structure for composing
; param      :: *psComposer - composer structure
;               *psData     - data structure
; returns    :: (nothing)
; ----------------------------------------
  
  ; //
  ; use Data XML
  ; //
  *psComposer\iXML = LENEX3Data::getData(*pData)

EndProcedure

Procedure enableFormattedOutput(*psComposer.COMPOSER)
; ----------------------------------------
; public     :: enable formatted xml output
; param      :: *psComposer - composer structure
; returns    :: (nothing)
; ----------------------------------------

  *psComposer\iFormat = #True

EndProcedure

Procedure disableFormattedOutput(*psComposer.COMPOSER)
; ----------------------------------------
; public     :: disable formatted xml output
; param      :: *psComposer - composer structure
; returns    :: (nothing)
; ----------------------------------------

  *psComposer\iFormat = #False

EndProcedure

Procedure.i composeMemory(*psComposer.COMPOSER)
; ----------------------------------------
; internal   :: get memory for lenex data
; param      :: *psComposer - composer structure
; returns    :: memory buffer pointer if success, 0 otherwise
; ----------------------------------------
  Protected.i iLen
  Protected *Buffer
; ----------------------------------------
  
  ; //
  ; check if xml is valid
  ; //
  If IsXML(*psComposer\iXML) = 0
    ProcedureReturn 0
  EndIf
  
  ; //
  ; format xml if enabled
  ; //
  If *psComposer\iFormat = #True
    FormatXML(*psComposer\iXML, #PB_XML_ReIndent | #PB_XML_ReFormat)
  EndIf
  
  ; //
  ; write data to memory
  ; //
  iLen    = ExportXMLSize(*psComposer\iXML)
  *Buffer = AllocateMemory(iLen)
  If ExportXML(*psComposer\iXML, *Buffer, iLen) <> 0
    ProcedureReturn *Buffer
  EndIf
  
  ProcedureReturn 0
  
EndProcedure

Procedure.i saveLEF(*psComposer.COMPOSER, pzPath.s)
; ----------------------------------------
; public     :: save lenex data as .lef file
; param      :: *psComposer - composer structure
;               pzPath      - file path
; returns    :: 1 if save was successful, 0 if not
; ----------------------------------------
  Protected.i iFile
  Protected *Buffer
; ----------------------------------------
  
  ; //
  ; validate filename
  ; //
  If GetExtensionPart(pzPath) <> "lef"
    pzPath + ".lef"
  EndIf
  
  ; //
  ; create file
  ; //
  iFile = CreateFile(#PB_Any, pzPath)
  If Not iFile
    ProcedureReturn 0
  EndIf
  
  ; //
  ; get memory
  ; //
  *Buffer = composeMemory(*psComposer)
  If Not *Buffer
    ProcedureReturn 0
  EndIf
  
  ; //
  ; write file
  ; //
  WriteData(iFile, *Buffer, MemorySize(*Buffer))
  CloseFile(iFile)
  
  ; //
  ; release memory
  ; //
  FreeMemory(*Buffer)
  
  ProcedureReturn 1
  
EndProcedure

Procedure.i saveLXF(*psComposer.COMPOSER, pzPath.s)
; ----------------------------------------
; public     :: save lenex data as .lxf file
; param      :: *psComposer - composer structure
;               pzPath      - file path
; returns    :: 1 if save was successful, 0 if not
; ----------------------------------------
  Protected.i iPack
  Protected *Buffer
; ----------------------------------------
  
  ; //
  ; validate filename
  ; //
  If GetExtensionPart(pzPath) <> "lxf"
    pzPath + ".lxf"
  EndIf
  
  ; //
  ; create archive
  ; //
  iPack = CreatePack(#PB_Any, pzPath, #PB_PackerPlugin_Zip)
  If Not iPack
    ProcedureReturn 0
  EndIf
  
  ; //
  ; get memory
  ; //
  *Buffer = composeMemory(*psComposer)
  If Not *Buffer
    ProcedureReturn 0
  EndIf
  
  ; //
  ; add data to archive
  ; //
  AddPackMemory(iPack, *Buffer, MemorySize(*Buffer), GetFilePart(pzPath, #PB_FileSystem_NoExtension) + ".lef")
  ClosePack(iPack)
  
  ; //
  ; release memory
  ; //
  FreeMemory(*Buffer)
  
  ProcedureReturn 1
  
EndProcedure

Procedure.s getString(*psComposer.COMPOSER)
; ----------------------------------------
; public     :: return lenex data as string
; param      :: *psComposer - composer structure
; returns    :: lenex data as string
; ----------------------------------------
  Protected.s zData
  Protected *Buffer
; ----------------------------------------
  
  ; //
  ; get memory
  ; //
  *Buffer = composeMemory(*psComposer)
  If Not *Buffer
    ProcedureReturn ""
  EndIf
  
  ; //
  ; get string
  ; //
  zData = PeekS(*Buffer, -1, #PB_UTF8)
  
  ; //
  ; release memory
  ; //
  FreeMemory(*Buffer)
  
  ProcedureReturn zData
  
EndProcedure

EndModule