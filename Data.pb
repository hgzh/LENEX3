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
Declare.i getAgedate(*pParent)
Declare.i createAgedate(*pParent)
Declare.i getFirstAgegroup(*pParent)
Declare.i getAgegroupByID(*pEvent, piID.i)
Declare.i createAgegroup(*pParent)
Declare.i getFirstAthlete(*pParent)
Declare.i getAthleteByID(*pMeet, piID)
Declare.i getAthleteByLicense(*pMeet, pzLicense.s)
Declare.i getAthleteByPersonalData(*pMeet, pzLastname.s, pzFirstname.s, pzGender.s)
Declare.i createAthlete(*pParent)
Declare.i getFirstClub(*pParent)
Declare.i getClubByName(*pMeet, pzName.s)
Declare.i createClub(*pParent)
Declare.i getFirstEntry(*pParent)
Declare.i getEntryByStart(*pMeet, piEventID.i, piHeatID.i, piLane.i)
Declare.i createEntry(*pParent)
Declare.i getFirstFee(*pParent)
Declare.i createFee(*pParent)
Declare.i getFirstHeat(*pEvent)
Declare.i getHeatByID(*pEvent, piID)
Declare.i getHeatByNumber(*pEvent, piNumber)
Declare.i createHeat(*pEvent)
Declare.i getFirstJudge(*pParent)
Declare.i createJudge(*pParent)
Declare.i getFirstMeet(*psData.LENEX)
Declare.i getMeetByName(*psData.LENEX, pzName.s)
Declare.i createMeet(*psData.LENEX)
Declare.i getMeetinfo(*pParent)
Declare.i createMeetinfo(*pParent)
Declare.i getFirstOfficial(*pClub)
Declare.i getOfficialByID(*pMeet, piID.i)
Declare.i createOfficial(*pClub)
Declare.i getPool(*pParent)
Declare.i createPool(*pParent)
Declare.i getFirstRanking(*pAgegroup)
Declare.i createRanking(*pAgegroup)
Declare.i getFirstRecordlist(*psData.LENEX)
Declare.i getRecordlistByName(*psData.LENEX, pzName.s)
Declare.i createRecordlist(*psData.LENEX)
Declare.i getFirstRelay(*pParent)
Declare.i createRelay(*pParent)
Declare.i getFirstRelayposition(*pParent)
Declare.i createRelayposition(*pParent)
Declare.i getFirstResult(*pParent)
Declare.i getResultByID(*pMeet, piID.i)
Declare.i getResultByStart(*pMeet, piEventID.i, piHeatID.i, piLane.i)
Declare.i createResult(*pParent)
Declare.i getFirstSession(*pMeet)
Declare.i getSessionByNumber(*pMeet, piNr.i)
Declare.i createSession(*pMeet)
Declare.i getFirstSplit(*pParent)
Declare.i getSplitByDistance(*pParent, piDistance.i)
Declare.i createSplit(*pParent)
Declare.i getSwimstyle(*pParent)
Declare.i createSwimstyle(*pParent)
Declare.i getFirstTimestandardlist(*psData.LENEX)
Declare.i getTimestandardlistByID(*psData.LENEX, piID.i)
Declare.i getTimestandardlistByName(*psData.LENEX, pzName.s)
Declare.i createTimestandardlist(*psData.LENEX)
Declare.i getFirstTimestandard(*pTimestandardlist)
Declare.i createTimestandard(*pTimestandardlist)
Declare.i getFirstTimestandardref(*pEvent)
Declare.i createTimestandardref(*pEvent)

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

Procedure.i traverseUpUntilElement(*pElem, pzName.s)
; ----------------------------------------
; internal   :: tries to find the first parent element that has the given name
; param      :: *pElem - start element
;               pzName - element to find
; returns    :: (i) pointer to element
; ----------------------------------------
  Protected *Node
; ----------------------------------------
  
  *Node = *pElem
  While *Node And UCase(GetXMLNodeName(*Node)) <> UCase(pzName)
    *Node = ParentXMLNode(*Node)
  Wend
  
  ProcedureReturn *Node

EndProcedure

Procedure.i getSubElementByID(*pParent, pzSubPath.s, pzIDAttribute.s, piID.i)
; ----------------------------------------
; internal   :: get the sub element with the given id
; param      :: *pParent      - parent element
;               pzSubPath     - additional sub path
;               pzIDAttribute - attribute containing the id
;               piID          - id value to look for
; returns    :: (i) pointer to sub element
; ----------------------------------------
  Protected *Elem
; ----------------------------------------
  
  ; //
  ; apply additional sub path or use parent element
  ; //
  If pzSubPath = ""
    *Elem = *pParent
  Else
    *Elem = XMLNodeFromPath(*pParent, pzSubPath)
  EndIf
  
  While *Elem
    If Val(getAttribute(*Elem, pzIDAttribute)) = piID
      ProcedureReturn *Elem
    EndIf
    *Elem = nextOf(*Elem)
  Wend
  
EndProcedure

Procedure.i getSubElementByValueMap(*pParent, pzSubPath.s, Map pmValueMap.s())
; ----------------------------------------
; internal   :: get the sub element with all the attributes matching the given map
; param      :: *pParent     - parent element
;               pzSubPath    - additional sub path
;               pmValueMap() - map with attribute -> value
; returns    :: (i) pointer to sub element
; ----------------------------------------
  Protected.i iFound
  Protected   *Elem
; ----------------------------------------
  
  ; //
  ; apply additional sub path or use parent element
  ; //
  If pzSubPath = ""
    *Elem = *pParent
  Else
    *Elem = XMLNodeFromPath(*pParent, pzSubPath)
  EndIf
  
  While *Elem
    iFound = 1
    ForEach pmValueMap()
      If getAttribute(*Elem, MapKey(pmValueMap())) <> pmValueMap()
        iFound = 0
        Break
      EndIf
    Next
    If iFound = 1
      ProcedureReturn *Elem
    EndIf
    *Elem = nextOf(*Elem)
  Wend
  
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

;- >>> age <<<

Procedure.i getAgedate(*pMeet)
; ----------------------------------------
; public     :: get the agedate of the meet
; param      :: *pMeet - meet pointer
; returns    :: (i) pointer to AGEDATE node
; ----------------------------------------

  ProcedureReturn XMLNodeFromPath(*pMeet, "AGEDATE")

EndProcedure

Procedure.i createAgedate(*pMeet)
; ----------------------------------------
; public     :: create AGEDATE element
; param      :: *pMeet - meet pointer
; returns    :: (i) pointer to new AGEDATE node
; ----------------------------------------
  
  ProcedureReturn createSubElement(*pMeet, "AGEDATE")

EndProcedure

Procedure.i getFirstAgegroup(*pParent)
; ----------------------------------------
; public     :: get the first fee element (either the event, the recordlist or the timestandardlist)
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to first AGEGROUP node
; ----------------------------------------
  Protected.s zParent
; ----------------------------------------
  
  zParent = UCase(GetXMLNodeName(*pParent))
  
  If zParent = "EVENT"
    ; //
    ; agegroup in event
    ; //
    ProcedureReturn XMLNodeFromPath(*pParent, "AGEGROUPS/AGEGROUP[1]")
  ElseIf zParent = "RECORDLIST" Or zParent = "TIMESTANDARDLIST"
    ; //
    ; agegroup in recordlist or timestandardref
    ; //
    ProcedureReturn XMLNodeFromPath(*pParent, "AGEGROUP")
  EndIf

EndProcedure

Procedure.i getAgegroupByID(*pEvent, piID.i)
; ----------------------------------------
; public     :: get the agegroup with the given ID in the event
; param      :: *pEvent - event pointer
;               piID    - agegroup identifier
; returns    :: (i) pointer to AGEGROUP node
; ----------------------------------------
  Protected *Agegroup
; ----------------------------------------
  
  ; //
  ; search agegroup in event
  ; //
  *Agegroup = getSubElementByID(*pEvent, "AGEGROUPS/AGEGROUP[1]", "agegroupid", piID)
  If *Agegroup
    ProcedureReturn *Agegroup
  EndIf
  
EndProcedure

Procedure.i createAgegroup(*pParent)
; ----------------------------------------
; public     :: create AGEGROUP element
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to new AGEGROUP node
; ----------------------------------------
  Protected.s zParent
; ----------------------------------------
  
  zParent = UCase(GetXMLNodeName(*pParent))
  
  If zParent = "EVENT"
    ; //
    ; agegroup in event
    ; //
    ProcedureReturn createSubElement(getCreateSubElement(*pParent, "AGEGROUPS"), "AGEGROUP")
  ElseIf zParent = "RECORDLIST" Or zParent = "TIMESTANDARDLIST"
    ; //
    ; agegroup in recordlist or timestandardref
    ; //
    ProcedureReturn createSubElement(*pParent, "AGEGROUP")
  EndIf

EndProcedure

;- >>> athletes <<<

Procedure.i getFirstAthlete(*pParent)
; ----------------------------------------
; public     :: get the first athlete element (either the club or the record or the record-relayposition)
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to first ATHLETE node
; ----------------------------------------
  Protected.s zParent
; ----------------------------------------
  
  zParent = UCase(GetXMLNodeName(*pParent))
  
  If zParent = "CLUB"
    ; //
    ; athlete in club
    ; //
    ProcedureReturn XMLNodeFromPath(*pParent, "ATHLETES/ATHLETE[1]")
  ElseIf zParent = "RECORD" Or zParent = "RELAYPOSITION"
    ; //
    ; athlete in record or in relayposition of record
    ; //
    ProcedureReturn XMLNodeFromPath(*pParent, "ATHLETE")
  EndIf

EndProcedure

Procedure.i getAthleteByID(*pMeet, piID)
; ----------------------------------------
; public     :: get the athlete with the given id in the meet
; param      :: *pMeet - meet pointer
;               piID   - athlete id
; returns    :: (i) pointer to ATHLETE node
; ----------------------------------------
  Protected *Athlete,
            *Parent
; ----------------------------------------
  
  ; //
  ; search athlete in clubs
  ; //
  *Parent = XMLNodeFromPath(*pMeet, "CLUBS/CLUB[1]")
  While *Parent
    *Athlete = getSubElementByID(*Parent, "ATHLETES/ATHLETE[1]", "athleteid", piID)
    If *Athlete
      ProcedureReturn *Athlete
    EndIf
    *Parent = nextOf(*Parent)
  Wend

EndProcedure

Procedure.i getAthleteByLicense(*pMeet, pzLicense.s)
; ----------------------------------------
; public     :: get the athlete with the given license in the meet
; param      :: *pMeet    - parent element pointer
;               pzLicense - athlete license
; returns    :: (i) pointer to ATHLETE node
; ----------------------------------------
  Protected *Athlete,
            *Parent
  Protected NewMap mValueMap.s()
; ----------------------------------------
  
  mValueMap("license") = pzLicense
  
  ; //
  ; search athlete in clubs
  ; //
  *Parent = XMLNodeFromPath(*pMeet, "CLUBS/CLUB[1]")
  While *Parent
    *Athlete = getSubElementByValueMap(*Parent, "ATHLETES/ATHLETE[1]", mValueMap())
    If *Athlete
      ProcedureReturn *Athlete
    EndIf
    *Parent = nextOf(*Parent)
  Wend

EndProcedure

Procedure.i getAthleteByPersonalData(*pMeet, pzLastname.s, pzFirstname.s, pzGender.s)
; ----------------------------------------
; public     :: get the athlete with the given personal data in the meet
; param      :: *pMeet      - meet pointer
;               pzLastname  - last name of the athlete
;               pzFirstname - first name of the athlete
;               pzGender    - gender of the athlete
; returns    :: (i) pointer to ATHLETE node
; ----------------------------------------
  Protected *Athlete,
            *Parent
  Protected NewMap mValueMap.s()
; ----------------------------------------
  
  mValueMap("lastname")  = pzLastname
  mValueMap("firstname") = pzFirstname
  mValueMap("gender")    = pzGender
  
  ; //
  ; search athlete in clubs
  ; //
  *Parent = XMLNodeFromPath(*pMeet, "CLUBS/CLUB[1]")
  While *Parent
    *Athlete = getSubElementByValueMap(*Parent, "ATHLETES/ATHLETE[1]", mValueMap())
    If *Athlete
      ProcedureReturn *Athlete
    EndIf
    *Parent = nextOf(*Parent)
  Wend

EndProcedure

Procedure.i createAthlete(*pParent)
; ----------------------------------------
; public     :: create ATHLETE element
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to new ATHLETE node
; ----------------------------------------
  Protected.s zParent
; ----------------------------------------
  
  zParent = UCase(GetXMLNodeName(*pParent))
  
  If zParent = "CLUB"
    ; //
    ; athlete in club
    ; //
    ProcedureReturn createSubElement(getCreateSubElement(*pParent, "ATHLETES"), "ATHLETE")
  ElseIf zParent = "RECORD" Or zParent = "RELAYPOSITION"
    ; //
    ; athlete in record or in relayposition of record
    ; //
    ProcedureReturn createSubElement(*pParent, "ATHLETE")
  EndIf

EndProcedure

;- >>> clubs <<<

Procedure.i getFirstClub(*pParent)
; ----------------------------------------
; public     :: get the first club element (either the meet or the record-athlete or the record-relay)
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to first CLUB node
; ----------------------------------------
  Protected.s zParent
; ----------------------------------------
  
  zParent = UCase(GetXMLNodeName(*pParent))
  
  If zParent = "MEET"
    ; //
    ; club in meet
    ; //
    ProcedureReturn XMLNodeFromPath(*pParent, "CLUBS/CLUB[1]")
  ElseIf zParent = "ATHLETE" Or zParent = "RELAY"
    ; //
    ; club in athlete or relay of a record
    ; //
    ProcedureReturn XMLNodeFromPath(*pParent, "CLUB")
  EndIf

EndProcedure

Procedure.i getClubByName(*pMeet, pzName.s)
; ----------------------------------------
; public     :: get the club with the given name in the meet
; param      :: *pMeet - meet pointer
;               pzName - club name
; returns    :: (i) pointer to CLUB node
; ----------------------------------------
  Protected *Club
; ----------------------------------------

  *Club = getFirstClub(*pMeet)
  While *Club
    If getAttribute(*Club, "name") = pzName
      ProcedureReturn *Club
    EndIf
    *Club = nextOf(*Club)
  Wend

EndProcedure

Procedure.i createClub(*pParent)
; ----------------------------------------
; public     :: create CLUB element
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to new CLUB node
; ----------------------------------------
  Protected.s zParent
; ----------------------------------------
  
  zParent = UCase(GetXMLNodeName(*pParent))
  
  If zParent = "CLUB"
    ; //
    ; club in meet
    ; //
    ProcedureReturn createSubElement(getCreateSubElement(*pParent, "CLUBS"), "CLUB")
  ElseIf zParent = "ATHLETE" Or zParent = "RELAY"
    ; //
    ; club in athlete or relay of a record
    ; //
    ProcedureReturn createSubElement(*pParent, "CLUB")
  EndIf

EndProcedure

;- >>> entries <<<

Procedure.i getFirstEntry(*pParent)
; ----------------------------------------
; public     :: get the first entry element (either of the athlete or the relay)
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to first ENTRY node
; ----------------------------------------
  
  ProcedureReturn XMLNodeFromPath(*pParent, "ENTRIES/ENTRY[1]")

EndProcedure

Procedure.i getEntryByStart(*pMeet, piEventID.i, piHeatID.i, piLane.i)
; ----------------------------------------
; public     :: get the entry by providing start information
; param      :: *pMeet    - meet pointer
;               piEventID - event identifier
;               piHeatID  - heat identifier
;               piLane    - lane number
; returns    :: (i) pointer to ENTRY node
; ----------------------------------------
  Protected *Entry,
            *Parent
  Protected NewMap mValueMap.s()
; ----------------------------------------
  
  mValueMap("eventid") = Str(piEventID)
  mValueMap("heatid")  = Str(piHeatID)
  mValueMap("lane")    = Str(piLane)
  
  ; //
  ; search entry in athletes
  ; //
  *Parent = XMLNodeFromPath(*pMeet, "ATHLETES/ATHLETE[1]")
  While *Parent
    *Entry = getSubElementByValueMap(*Parent, "ENTRIES/ENTRY[1]", mValueMap())
    If *Entry
      ProcedureReturn *Entry
    EndIf
    *Parent = nextOf(*Parent)
  Wend

  ; //
  ; search entry in relays
  ; //
  *Parent = XMLNodeFromPath(*pMeet, "RELAYS/RELAY[1]")
  While *Parent
    *Entry = getSubElementByValueMap(*Parent, "ENTRIES/ENTRY[1]", mValueMap())
    If *Entry
      ProcedureReturn *Entry
    EndIf
    *Parent = nextOf(*Parent)
  Wend

EndProcedure

Procedure.i createEntry(*pParent)
; ----------------------------------------
; public     :: create ENTRY element
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to new ENTRY node
; ----------------------------------------
 
  ProcedureReturn createSubElement(getCreateSubElement(*pParent, "ENTRIES"), "ENTRY")

EndProcedure

;- >>> fees <<<

Procedure.i getFirstFee(*pParent)
; ----------------------------------------
; public     :: get the first fee element (either the meet, the session, the event or the timestandardref)
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to first FEE node
; ----------------------------------------
  Protected.s zParent
; ----------------------------------------
  
  zParent = UCase(GetXMLNodeName(*pParent))
  
  If zParent = "MEET" Or zParent = "SESSION" 
    ; //
    ; fee in meet or session
    ; //
    ProcedureReturn XMLNodeFromPath(*pParent, "FEES/FEE[1]")
  ElseIf zParent = "EVENT" Or zParent = "TIMESTANDARDREF"
    ; //
    ; fee in event or timestandardref
    ; //
    ProcedureReturn XMLNodeFromPath(*pParent, "FEE")
  EndIf

EndProcedure

Procedure.i createFee(*pParent)
; ----------------------------------------
; public     :: create FEE element
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to new FEE node
; ----------------------------------------
  Protected.s zParent
; ----------------------------------------
  
  zParent = UCase(GetXMLNodeName(*pParent))
  
  If zParent = "MEET" Or zParent = "SESSION" 
    ; //
    ; fee in meet or session
    ; //
    ProcedureReturn createSubElement(getCreateSubElement(*pParent, "FEES"), "FEE")
  ElseIf zParent = "EVENT" Or zParent = "TIMESTANDARDREF"
    ; //
    ; fee in event or timestandardref
    ; //
    ProcedureReturn createSubElement(*pParent, "FEE")
  EndIf

EndProcedure

;- >>> heats <<<

Procedure.i getFirstHeat(*pEvent)
; ----------------------------------------
; public     :: get the first heat of the event
; param      :: *pEvent - event pointer
; returns    :: (i) pointer to first HEAT node
; ----------------------------------------
  
  ProcedureReturn XMLNodeFromPath(*pEvent, "HEATS/HEAT[1]")

EndProcedure

Procedure.i getHeatByID(*pEvent, piID.i)
; ----------------------------------------
; public     :: get the heat with the given ID in the event
; param      :: *pEvent - event pointer
;               piID    - heat identifier
; returns    :: (i) pointer to HEAT node
; ----------------------------------------
  Protected *Heat
; ----------------------------------------
  
  ; //
  ; search heat in event
  ; //
  *Heat = getSubElementByID(*pEvent, "HEATS/HEAT[1]", "heatid", piID)
  If *Heat
    ProcedureReturn *Heat
  EndIf
  
EndProcedure

Procedure.i getHeatByNumber(*pEvent, piNumber.i)
; ----------------------------------------
; public     :: get the heat with the given number in the event
; param      :: *pEvent  - event pointer
;               piNumber - heat number
; returns    :: (i) pointer to HEAT node
; ----------------------------------------
  Protected *Heat
; ----------------------------------------
  
  ; //
  ; search heat in event
  ; //
  *Heat = getSubElementByID(*pEvent, "HEATS/HEAT[1]", "number", piNumber)
  If *Heat
    ProcedureReturn *Heat
  EndIf
  
EndProcedure

Procedure.i createHeat(*pEvent)
; ----------------------------------------
; public     :: create HEAT element
; param      :: *pEvent - event pointer
; returns    :: (i) pointer to new HEAT node
; ----------------------------------------
 
  ProcedureReturn createSubElement(getCreateSubElement(*pEvent, "HEATS"), "HEAT")

EndProcedure

;- >>> judges <<<

Procedure.i getFirstJudge(*pSession)
; ----------------------------------------
; public     :: get the first judge in the session
; param      :: *pSession - session pointer
; returns    :: (i) pointer to first JUDGE node
; ----------------------------------------

  ProcedureReturn XMLNodeFromPath(*pSession, "JUDGES/JUDGE[1]")

EndProcedure

Procedure.i createJudge(*pSession)
; ----------------------------------------
; public     :: create JUDGE element
; param      :: *pSession - session pointer
; returns    :: (i) pointer to new RELAY node
; ----------------------------------------

  ProcedureReturn createSubElement(getCreateSubElement(*pSession, "JUDGES"), "JUDGE")

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

Procedure.i getMeetinfo(*pParent)
; ----------------------------------------
; public     :: get the meetinfo of the entry, relayposition or record
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to MEETINFO node
; ----------------------------------------

  ProcedureReturn XMLNodeFromPath(*pParent, "MEETINFO")

EndProcedure

Procedure.i createMeetinfo(*pParent)
; ----------------------------------------
; public     :: create MEETINFO element
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to new MEETINFO node
; ----------------------------------------
  
  ProcedureReturn createSubElement(*pParent, "MEETINFO")

EndProcedure

;- >>> officials <<<

Procedure.i getFirstOfficial(*pClub)
; ----------------------------------------
; public     :: get the first official of the CLUB
; param      :: *pClub - club pointer
; returns    :: (i) pointer to first OFFICIAL node
; ----------------------------------------
  
  ProcedureReturn XMLNodeFromPath(*pClub, "OFFICIALS/OFFICIAL[1]")

EndProcedure

Procedure.i getOfficialByID(*pMeet, piID.i)
; ----------------------------------------
; public     :: get the official with the given ID in the meet
; param      :: *pMeet - meet pointer
;               piID   - official identifier
; returns    :: (i) pointer to OFFICIAL node
; ----------------------------------------
  Protected *Official,
            *Parent
; ----------------------------------------
  
  ; //
  ; search official in clubs
  ; //
  *Parent = XMLNodeFromPath(*pMeet, "CLUBS/CLUB[1]")
  While *Parent
    *Official = getSubElementByID(*Parent, "OFFICIALS/OFFICIAL[1]", "officialid", piID)
    If *Official
      ProcedureReturn *Official
    EndIf
    *Parent = nextOf(*Parent)
  Wend
  
EndProcedure

Procedure.i createOfficial(*pClub)
; ----------------------------------------
; public     :: create OFFICIAL element
; param      :: *pClub - club pointer
; returns    :: (i) pointer to new CLUB node
; ----------------------------------------
 
  ProcedureReturn createSubElement(getCreateSubElement(*pClub, "OFFICIALS"), "OFFICIAL")

EndProcedure

;- >>> pool <<<

Procedure.i getPool(*pParent)
; ----------------------------------------
; public     :: get the pool of the meet, session or meetinfo
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to MEETINFO node
; ----------------------------------------

  ProcedureReturn XMLNodeFromPath(*pParent, "POOL")

EndProcedure

Procedure.i createPool(*pParent)
; ----------------------------------------
; public     :: create POOL element
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to new POOL node
; ----------------------------------------
  
  ProcedureReturn createSubElement(*pParent, "POOL")

EndProcedure

;- >>> rankings <<<

Procedure.i getFirstRanking(*pAgegroup)
; ----------------------------------------
; public     :: get the first ranking in the agegroup
; param      :: *pAgegroup - agegroup pointer
; returns    :: (i) pointer to first JUDGE node
; ----------------------------------------

  ProcedureReturn XMLNodeFromPath(*pAgegroup, "RANKINGS/RANKING[1]")

EndProcedure

Procedure.i createRanking(*pAgegroup)
; ----------------------------------------
; public     :: create RANKING element
; param      :: *pAgegroup - agegroup pointer
; returns    :: (i) pointer to new RANKING node
; ----------------------------------------

  ProcedureReturn createSubElement(getCreateSubElement(*pAgegroup, "RANKINGS"), "RANKING")

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

Procedure.i getFirstRecord(*pRecordlist)
; ----------------------------------------
; public     :: get the first meet in the RECORDS collection
; param      :: *pRecordlist - recordlist pointer
; returns    :: (i) pointer to first RECORD node
; ----------------------------------------

  ProcedureReturn XMLNodeFromPath(*pRecordlist, "RECORDS/RECORD[1]")

EndProcedure

Procedure.i createRecord(*pRecordlist)
; ----------------------------------------
; public     :: create RECORD element
; param      :: *pRecordlist - recordlist pointer
; returns    :: (i) pointer to new RECORD node
; ----------------------------------------
  
  ProcedureReturn createSubElement(getCreateSubElement(*pRecordlist, "RECORDS"), "RECORD")

EndProcedure

;- >>> relays <<<

Procedure.i getFirstRelay(*pParent)
; ----------------------------------------
; public     :: get the first relay element (either the club or the record)
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to first RELAY node
; ----------------------------------------
  Protected.s zParent
; ----------------------------------------
  
  zParent = UCase(GetXMLNodeName(*pParent))
  
  If zParent = "CLUB"
    ; //
    ; relay in club
    ; //
    ProcedureReturn XMLNodeFromPath(*pParent, "RELAYS/RELAY[1]")
  ElseIf zParent = "RECORD"
    ; //
    ; relay in record
    ; //
    ProcedureReturn XMLNodeFromPath(*pParent, "RELAY")
  EndIf

EndProcedure

Procedure.i createRelay(*pParent)
; ----------------------------------------
; public     :: create RELAY element
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to new RELAY node
; ----------------------------------------
  Protected.s zParent
; ----------------------------------------
  
  zParent = UCase(GetXMLNodeName(*pParent))
  
  If zParent = "CLUB"
    ; //
    ; relay in club
    ; //
    ProcedureReturn createSubElement(getCreateSubElement(*pParent, "RELAYS"), "RELAY")
  ElseIf zParent = "RECORD"
    ; //
    ; relay in record
    ; //
    ProcedureReturn createSubElement(*pParent, "RELAY")
  EndIf

EndProcedure

Procedure.i getFirstRelayposition(*pParent)
; ----------------------------------------
; public     :: get the first relayposition element (either the entry, the result or the record-relay)
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to first RELAYPOSITION node
; ----------------------------------------
  Protected.s zParent
; ----------------------------------------
  
  ProcedureReturn XMLNodeFromPath(*pParent, "RELAYPOSITIONS/RELAYPOSITION[1]")

EndProcedure

Procedure.i createRelayposition(*pParent)
; ----------------------------------------
; public     :: create RELAYPOSITION element
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to new RELAYPOSITION node
; ----------------------------------------

  ProcedureReturn createSubElement(getCreateSubElement(*pParent, "RELAYPOSITIONS"), "RELAYPOSITION")

EndProcedure

;- >>> results <<<

Procedure.i getFirstResult(*pParent)
; ----------------------------------------
; public     :: get the first result element (either of the athlete or the relay)
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to first RESULT node
; ----------------------------------------
  
  ProcedureReturn XMLNodeFromPath(*pParent, "RESULTS/RESULT[1]")

EndProcedure

Procedure.i getResultByID(*pMeet, piID.i)
; ----------------------------------------
; public     :: get the result with the given ID in the meet
; param      :: *pMeet - meet pointer
;               piID   - result identifier
; returns    :: (i) pointer to RESULT node
; ----------------------------------------
  Protected *Result,
            *Parent
; ----------------------------------------
  
  ; //
  ; search result in athletes
  ; //
  *Parent = XMLNodeFromPath(*pMeet, "ATHLETES/ATHLETE[1]")
  While *Parent
    *Result = getSubElementByID(*Parent, "RESULTS/RESULT[1]", "resultid", piID)
    If *Result
      ProcedureReturn *Result
    EndIf
    *Parent = nextOf(*Parent)
  Wend
  
  ; //
  ; search result in relays
  ; //
  *Parent = XMLNodeFromPath(*pMeet, "RELAYS/RELAY[1]")
  While *Parent
    *Result = getSubElementByID(*Parent, "RESULTS/RESULT[1]", "resultid", piID)
    If *Result
      ProcedureReturn *Result
    EndIf
    *Parent = nextOf(*Parent)
  Wend
  
EndProcedure

Procedure.i getResultByStart(*pMeet, piEventID.i, piHeatID.i, piLane.i)
; ----------------------------------------
; public     :: get the result by providing start information
; param      :: *pMeet    - meet pointer
;               piEventID - event identifier
;               piHeatID  - heat identifier
;               piLane    - lane number
; returns    :: (i) pointer to RESULT node
; ----------------------------------------
  Protected *Result,
            *Parent
  Protected NewMap mValueMap.s()
; ----------------------------------------
  
  mValueMap("eventid") = Str(piEventID)
  mValueMap("heatid")  = Str(piHeatID)
  mValueMap("lane")    = Str(piLane)
  
  ; //
  ; search result in athletes
  ; //
  *Parent = XMLNodeFromPath(*pMeet, "ATHLETES/ATHLETE[1]")
  While *Parent
    *Result = getSubElementByValueMap(*Parent, "RESULTS/RESULT[1]", mValueMap())
    If *Result
      ProcedureReturn *Result
    EndIf
    *Parent = nextOf(*Parent)
  Wend

  ; //
  ; search result in relays
  ; //
  *Parent = XMLNodeFromPath(*pMeet, "RELAYS/RELAY[1]")
  While *Parent
    *Result = getSubElementByValueMap(*Parent, "RESULTS/RESULT[1]", mValueMap())
    If *Result
      ProcedureReturn *Result
    EndIf
    *Parent = nextOf(*Parent)
  Wend
  
EndProcedure

Procedure.i createResult(*pParent)
; ----------------------------------------
; public     :: create RESULT element
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to new RESULT node
; ----------------------------------------
 
  ProcedureReturn createSubElement(getCreateSubElement(*pParent, "RESULTS"), "RESULT")

EndProcedure

;- >>> sessions <<<

Procedure.i getFirstSession(*pMeet)
; ----------------------------------------
; public     :: get the first session in the MEET
; param      :: *pMeet - meet pointer
; returns    :: (i) pointer to first SESSION node
; ----------------------------------------

  ProcedureReturn XMLNodeFromPath(*pMeet, "SESSIONS/SESSION[1]")

EndProcedure

Procedure.i getSessionByNumber(*pMeet, piNr.i)
; ----------------------------------------
; public     :: get the session with the given number in the meet
; param      :: *pMeet - meet pointer
;               piNr   - session number
; returns    :: (i) pointer to SESSION node
; ----------------------------------------
  Protected *Session
; ----------------------------------------

  *Session = getFirstSession(*pMeet)
  While *Session
    If Val(getAttribute(*Session, "number")) = piNr
      ProcedureReturn *Session
    EndIf
    *Session = nextOf(*Session)
  Wend

EndProcedure

Procedure.i createSession(*pMeet)
; ----------------------------------------
; public     :: create MEET element
; param      :: *pMeet - meet pointer
; returns    :: (i) pointer to new SESSION node
; ----------------------------------------
  
  ProcedureReturn createSubElement(getCreateSubElement(*pMeet, "SESSIONS"), "SESSION")

EndProcedure

;- >>> splits <<<

Procedure.i getFirstSplit(*pParent)
; ----------------------------------------
; public     :: get the first entry element (either of the result or the record)
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to first SPLIT node
; ----------------------------------------
  
  ProcedureReturn XMLNodeFromPath(*pParent, "SPLITS/SPLIT[1]")

EndProcedure

Procedure.i getSplitByDistance(*pParent, piDistance.i)
; ----------------------------------------
; public     :: get the split at the given distance
; param      :: *pParent   - parent element pointer
;               piDistance - distance
; returns    :: (i) pointer to SPLIT node
; ----------------------------------------
  Protected *Split
; ----------------------------------------

  *Split = getFirstSplit(*pParent)
  While *Split
    If Val(getAttribute(*Split, "distance")) = piDistance
      ProcedureReturn *Split
    EndIf
    *Split = nextOf(*Split)
  Wend

EndProcedure

Procedure.i createSplit(*pParent)
; ----------------------------------------
; public     :: create SPLIT element
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to new SPLIT node
; ----------------------------------------
 
  ProcedureReturn createSubElement(getCreateSubElement(*pParent, "SPLITS"), "SPLIT")

EndProcedure

;- >>> swimstyle <<<

Procedure.i getSwimstyle(*pParent)
; ----------------------------------------
; public     :: get the swimstyle
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to SWIMSTYLE node
; ----------------------------------------

  ProcedureReturn XMLNodeFromPath(*pParent, "SWIMSTYLE")

EndProcedure

Procedure.i createSwimstyle(*pParent)
; ----------------------------------------
; public     :: create SWIMSTYLE element
; param      :: *pParent - parent element pointer
; returns    :: (i) pointer to new SWIMSTYLE node
; ----------------------------------------
  
  ProcedureReturn createSubElement(*pParent, "SWIMSTYLE")

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
; param      :: *pTimestandardlist - timestandardlist pointer
; returns    :: (i) pointer to first TIMESTANDARD node
; ----------------------------------------

  ProcedureReturn XMLNodeFromPath(*pTimestandardlist, "TIMESTANDARDS/TIMESTANDARD[1]")

EndProcedure

Procedure.i createTimestandard(*pTimestandardlist)
; ----------------------------------------
; public     :: create TIMESTANDARD element
; param      :: *pTimestandardlist - timestandardlist pointer
; returns    :: (i) pointer to new TIMESTANDARD node
; ----------------------------------------
  
  ProcedureReturn createSubElement(getCreateSubElement(*pTimestandardlist, "TIMESTANDARDS"), "TIMESTANDARD")

EndProcedure

Procedure.i getFirstTimestandardref(*pEvent)
; ----------------------------------------
; public     :: get the first meet in the TIMESTANDARDREFS collection
; param      :: *pEvent - event pointer
; returns    :: (i) pointer to first TIMESTANDARDREF node
; ----------------------------------------

  ProcedureReturn XMLNodeFromPath(*pEvent, "TIMESTANDARDREFS/TIMESTANDARDREF[1]")

EndProcedure

Procedure.i createTimestandardref(*pEvent)
; ----------------------------------------
; public     :: create TIMESTANDARDREF element
; param      :: *pEvent - event pointer
; returns    :: (i) pointer to new TIMESTANDARDREF node
; ----------------------------------------
  
  ProcedureReturn createSubElement(getCreateSubElement(*pEvent, "TIMESTANDARDREFS"), "TIMESTANDARDREF")

EndProcedure

EndModule