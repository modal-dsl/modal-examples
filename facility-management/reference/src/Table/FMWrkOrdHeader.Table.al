table 50004 "FM Wrk. Ord. Header"
{
    Caption = 'Work Order Header';
    DataCaptionFields = "No.";
    LookupPageId = "FM Work Order";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    GetAptSetup();
                    NoSeriesMgt.TestManual(AptSetup."Wrk. Ord. Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Apartment No."; Code[20])
        {
            Caption = 'Apartment No.';
            TableRelation = "FM Apartment";

            trigger OnValidate()
            begin
                if "No." = '' then
                    InitRecord;

                TestStatusPlanning();
                if ("Apartment No." <> xRec."Apartment No.") and (xRec."Apartment No." <> '') then begin
                    if GetHideValidationDialog or not GuiAllowed then
                        Confirmed := true
                    else
                        Confirmed := Confirm(ConfirmChangeQst, false, FieldCaption("Apartment No."));

                    if Confirmed then begin
                        WrkOrdLine.SetRange("Document No.", "No.");
                        if "Apartment No." = '' then begin
                            if not WrkOrdLine.IsEmpty then
                                Error(ExistingLinesErr, FieldCaption("Apartment No."));
                            Init();
                            OnValidateAptNoAfterInit(Rec, xRec);
                            GetAptSetup();
                            "No. Series" := xRec."No. Series";
                            InitRecord();
                            InitNoSeries();
                            exit;
                        end;

                        WrkOrdLine.Reset();
                    end else begin
                        Rec := xRec;
                        exit;
                    end;
                end;

                GetApt("Apartment No.");
                Apt.TestBlocked();
                OnAfterCheckAptNo(Rec, xRec, Apt);
                
                
                "Apt. Description 2" := Apt."Description 2";
                "Apt. Description" := Apt.Description;
                
                "Apt. Address 2" := Apt."Address 2";
                "Apt. Post Code" := Apt."Post Code";
                "Apt. City" := Apt.City;
                "Apt. County" := Apt.County;
                "Apt. Address" := Apt.Address;
                "Apt. Country/Region Code" := Apt."Country/Region Code";
            end;
        }
        field(3; Status; Enum "FM Work Order Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        
        field(4; Comment; Boolean)
        {
            Caption = 'Comment';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = exist ("FM Apartment Comment Line" where("No." = field("No."), "Document Line No." = const(0)));
        }
        field(5; "No. Printed"; Integer)
        {
            Caption = 'No. Printed';
            Editable = false;
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                TestField("Posting Date");
                TestNoSeriesDate("Posting No.", "Posting No. Series",
                    FieldCaption("Posting No."), FieldCaption("Posting No. Series"));

                IsHandled := false;
                OnValidatePostingDateOnBeforeAssignDocumentDate(Rec, IsHandled);
                if not IsHandled then
                    Validate("Document Date", "Posting Date");
            end;
        }
        field(7; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(8; "Posting Description"; Text[100])
        {
            Caption = 'Posting Description';
        }
        field(9; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(10; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(11; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(12; "Posting No."; Code[20])
        {
            Caption = 'Posting No.';
        }
        field(13; "Posting No. Series"; Code[20])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";

            trigger OnLookup()
            begin
                WrkOrdHeader := Rec;
                GetAptSetup();
                TestNoSeries();
                if NoSeriesMgt.LookupSeries(GetPostingNoSeriesCode, WrkOrdHeader."Posting No. Series") then
                    WrkOrdHeader.Validate("Posting No. Series");
                Rec := WrkOrdHeader;
            end;

            trigger OnValidate()
            begin
                if "Posting No. Series" <> '' then begin
                    GetAptSetup();
                    TestNoSeries();
                    NoSeriesMgt.TestSeries(GetPostingNoSeriesCode, "Posting No. Series");
                end;
                TestField("Posting No.", '');
            end;
        }
        field(14; "Last Posting No."; Code[20])
        {
            Caption = 'Last Posting No.';
            Editable = false;
            TableRelation = "FM Posted Work Order Header";
        }
        field(15; "Mt. Wk. Code"; Code[10])
        {
        	Caption = 'Mt. Wk. Code';
        	TableRelation = "FM Maintenance Worker";
        	
        	trigger OnValidate()
        	begin
        		TestStatusPlanning();
        		if ("Mt. Wk. Code" <> xRec."Mt. Wk. Code") and (xRec."Mt. Wk. Code" <> '') then begin
        			if GetHideValidationDialog or not GuiAllowed then
        				Confirmed := true
        			else
        				Confirmed := Confirm(ConfirmChangeQst, false, FieldCaption("Mt. Wk. Code"));
        			
        			if Confirmed then begin
        				if "Mt. Wk. Code" = '' then
        					exit;
        			end else begin
        				Rec := xRec;
        				exit;
        			end;
        		end;
        		
        		If "Mt. Wk. Code" = '' then
        			MtWrk.Init()
        		else begin
        			GetMtWrk("Mt. Wk. Code");
        			MtWrk.TestBlocked;
        		end;
        		
        		
        		"Mt. Wrk. Name 2" := MtWrk."Name 2";
        		"Mt. Wrk. Name" := MtWrk.Name;
        	end;
        }
        field(16; "Finish Until"; Date)
        {
        	Caption = 'Finish Until';
        }
        field(17; "Requested By"; Text[50])
        {
        	Caption = 'Requested By';
        }
        field(18; "Apt. Description"; Text[100])
        {
        	Caption = 'Apt. Description';
        	
        }
        field(19; "Apt. Description 2"; Text[50])
        {
        	Caption = 'Apt. Description 2';
        }
        field(20; "Apt. Address"; Text[100])
        {
        	Caption = 'Apt. Address';
        }
        field(21; "Apt. Address 2"; Text[50])
        {
        	Caption = 'Apt. Address 2';
        }
        field(22; "Apt. City"; Text[30])
        {
        	Caption = 'Apt. City';
        	TableRelation = if ("Apt. Country/Region Code" = const('')) "Post Code".City
        	else
        	if ("Apt. Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Apt. Country/Region Code"));
        	ValidateTableRelation = false;
        	
        	trigger OnLookup()
        	begin
        		OnBeforeLookupCity(Rec, PostCode);
        		
        		PostCode.LookupPostCode("Apt. City", "Apt. Post Code", "Apt. County", "Apt. Country/Region Code");
        	end;
        	
        	trigger OnValidate()
        	begin
        	OnBeforeValidateCity(Rec, PostCode);
        	
        	PostCode.ValidateCity("Apt. City", "Apt. Post Code", "Apt. County", "Apt. Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
        	end;
        }
        field(23; "Apt. Country/Region Code"; Code[10])
        {
        	Caption = 'Apt. Country/Region Code';
        	TableRelation = "Country/Region";
        	
        	trigger OnValidate()
        	begin
        		PostCode.CheckClearPostCodeCityCounty("Apt. City", "Apt. Post Code", "Apt. County", "Apt. Country/Region Code", xRec."Apt. Country/Region Code");
        	end;
        }
        field(24; "Apt. Post Code"; Code[20])
        {
        	Caption = 'Apt. Post Code';
        	TableRelation = if ("Apt. Country/Region Code" = const('')) "Post Code"
        	else
        	if ("Apt. Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Apt. Country/Region Code"));
        	ValidateTableRelation = false;
        	
        	trigger OnLookup()
        	begin
        		OnBeforeLookupPostCode(Rec, PostCode);
        		
        		PostCode.LookupPostCode("Apt. City", "Apt. Post Code", "Apt. County", "Apt. Country/Region Code");
        	end;
        	
        	trigger OnValidate()
        	begin
        		OnBeforeValidatePostCode(Rec, PostCode);
        		
        		PostCode.ValidatePostCode("Apt. City", "Apt. Post Code", "Apt. County", "Apt. Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
        	end;
        }
        field(25; "Apt. County"; Text[30])
        {
        	CaptionClass = '5,1,' + "Apt. Country/Region Code";
        	Caption = 'Apt. County';
        }
        field(26; "Mt. Wrk. Name"; Text[100])
        {
        	Caption = 'Mt. Wrk. Name';
        	
        }
        field(27; "Mt. Wrk. Name 2"; Text[50])
        {
        	Caption = 'Mt. Wrk. Name 2';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Apartment No.") { }
    }

    var
    	NoSeriesMgt: Codeunit NoSeriesManagement;
        AptSetup: Record "FM Apartment Setup";
        AptSetupRead: Boolean;
        Apt: Record "FM Apartment";
        MtWrk: Record "FM Maintenance Worker";
        WrkOrdHeader: Record "FM Wrk. Ord. Header";
        WrkOrdLine: Record "FM Wrk. Ord. Line";
        AptCommentLine: Record "FM Apartment Comment Line";
        PostingDescrTxt: Label 'Wrk. Ord.';
        Confirmed: Boolean;
        ConfirmChangeQst: Label 'Do you want to change %1?';
        SelectNoSeriesAllowed: Boolean;
        AlreadyExistsErr: Label 'The %1 %2 already exists.';
        HideValidationDialog: Boolean;
        StatusCheckSuspended: Boolean;
        ExistingLinesErr: Label 'You cannot reset %1 because the document still has one or more lines.';
        RenameNotAllowedErr: Label 'You cannot rename a %1.';
        NoSeriesDateOrderErr: Label 'You can not change the %1 field because %2 %3 has %4 = %5 and the document has already been assigned %6 %7.';
    	PostCode: Record "Post Code";

    trigger OnInsert()
    begin
        IF "No." = '' THEN BEGIN
            GetAptSetup;
            AptSetup.TESTFIELD("Wrk. Ord. Nos.");
            NoSeriesMgt.InitSeries(AptSetup."Wrk. Ord. Nos.", xRec."No. Series", "Posting Date", "No.", "No. Series");
        END;

        InitRecord;

        if GetFilterAptNo <> '' then
            Validate("Apartment No.", GetFilterAptNo);
		
		if GetFilterMtWrkCode <> '' then
			Validate("Mt. Wk. Code", GetFilterMtWrkCode);
    end;

    trigger OnRename()
    begin
        Error(RenameNotAllowedErr, TableCaption);
    end;

    trigger OnDelete()
    begin
        AptCommentLine.SetRange("Document Type", AptCommentLine."Document Type"::"Work Order");
        AptCommentLine.SetRange("No.", "No.");
        AptCommentLine.DeleteAll();
        
        WrkOrdLine.DeleteAll();
    end;

    local procedure GetFilterAptNo(): Code[20]
    begin
        if GetFilter("Apartment No.") <> '' then
            if GetRangeMin("Apartment No.") = GetRangeMax("Apartment No.") then
                exit(GetRangeMax("Apartment No."));
    end;
	
	local procedure GetFilterMtWrkCode(): Code[20]
		begin
			if GetFilter("Mt. Wk. Code") <> '' then
				if GetRangeMin("Mt. Wk. Code") = GetRangeMax("Mt. Wk. Code") then
					exit(GetRangeMax("Mt. Wk. Code"));
		end;

    procedure InitRecord()
    var
        IsHandled: Boolean;
    begin
        GetAptSetup();

        IsHandled := false;
        OnBeforeInitRecord(Rec, IsHandled, xRec);
        if not IsHandled then
            NoSeriesMgt.SetDefaultSeries("Posting No. Series", AptSetup."Posted Wrk. Ord. Nos.");

        if "Posting Date" = 0D then
            "Posting Date" := WorkDate();

        "Document Date" := WorkDate();
        "Posting Description" := PostingDescrTxt + ' ' + "No.";

        OnAfterInitRecord(Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitRecord(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var IsHandled: Boolean; xWrkOrdHeader: Record "FM Wrk. Ord. Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRecord(var WrkOrdHeader: Record "FM Wrk. Ord. Header")
    begin
    end;

    local procedure InitNoSeries()
    begin
        if xRec."Posting No." <> '' then begin
            "Posting No. Series" := xRec."Posting No. Series";
            "Posting No." := xRec."Posting No.";
        end;

        OnAfterInitNoSeries(Rec, xRec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitNoSeries(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; xWrkOrdHeader: Record "FM Wrk. Ord. Header")
    begin
    end;

    procedure AssistEdit(OldWrkOrdHeader: Record "FM Wrk. Ord. Header"): Boolean
    var
        WrkOrdHeader2: Record "FM Wrk. Ord. Header";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAssistEdit(Rec, OldWrkOrdHeader, IsHandled);
        if IsHandled then
            exit;

        WrkOrdHeader.Copy(Rec);
        GetAptSetup();
        TestNoSeries();
        if NoSeriesMgt.SelectSeries(WrkOrdHeader.GetNoSeriesCode(), OldWrkOrdHeader."No. Series", WrkOrdHeader."No. Series") then begin
            NoSeriesMgt.SetSeries(WrkOrdHeader."No.");
            if WrkOrdHeader2.Get(WrkOrdHeader."No.") then
                Error(AlreadyExistsErr, TableCaption, WrkOrdHeader."No.");
            Rec := WrkOrdHeader;
            exit(true);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAssistEdit(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; OldWrkOrdHeader: Record "FM Wrk. Ord. Header"; var IsHandled: Boolean)
    begin
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    procedure GetHideValidationDialog(): Boolean
    begin
        exit(HideValidationDialog);
    end;

    procedure GetNoSeriesCode(): Code[20]
    var
        NoSeriesCode: Code[20];
        IsHandled: Boolean;
    begin
        GetAptSetup();
        
        IsHandled := false;
        OnBeforeGetNoSeriesCode(Rec, AptSetup, NoSeriesCode, IsHandled);
        if IsHandled then
            exit;

        NoSeriesCode := AptSetup."Wrk. Ord. Nos.";

        OnAfterGetNoSeriesCode(Rec, AptSetup, NoSeriesCode);
        exit(NoSeriesMgt.GetNoSeriesWithCheck(NoSeriesCode, SelectNoSeriesAllowed, "No. Series"));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetNoSeriesCode(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; AptSetup: Record "FM Apartment Setup"; var NoSeriesCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetNoSeriesCode(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; AptSetup: Record "FM Apartment Setup"; var NoSeriesCode: Code[20])
    begin
    end;

    procedure SetAllowSelectNoSeries()
    begin
        SelectNoSeriesAllowed := true;
    end;

    procedure TestNoSeries()
    var
        IsHandled: Boolean;
    begin
        GetAptSetup();

        IsHandled := false;
        OnBeforeTestNoSeries(Rec, IsHandled);
        if IsHandled then
            exit;

        AptSetup.TestField("Wrk. Ord. Nos.");

        OnAfterTestNoSeries(Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestNoSeries(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestNoSeries(var WrkOrdHeader: Record "FM Wrk. Ord. Header")
    begin
    end;

    local procedure TestNoSeriesDate(No: Code[20]; NoSeriesCode: Code[20]; NoCapt: Text[1024]; NoSeriesCapt: Text[1024])
    var
        NoSeries: Record "No. Series";
    begin
        if (No <> '') and (NoSeriesCode <> '') then begin
            NoSeries.Get(NoSeriesCode);
            if NoSeries."Date Order" then
                Error(
                  NoSeriesDateOrderErr,
                  FieldCaption("Posting Date"), NoSeriesCapt, NoSeriesCode,
                  NoSeries.FieldCaption("Date Order"), NoSeries."Date Order",
                  NoCapt, No);
        end;
    end;

    procedure TestStatusPlanning()
    begin
        OnBeforeTestStatusPlanning(Rec);

        if StatusCheckSuspended then
            exit;

        TestField(Status, Status::Planning);

        OnAfterTestStatusPlanning(Rec);
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnBeforeTestStatusPlanning(var WrkOrdHeader: Record "FM Wrk. Ord. Header")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterTestStatusPlanning(var WrkOrdHeader: Record "FM Wrk. Ord. Header")
    begin
    end;

    procedure SuspendStatusCheck(Suspend: Boolean)
    begin
        StatusCheckSuspended := Suspend;
    end;

    local procedure GetApt(AptNo: Code[20])
    begin
        if not (AptNo = '') then begin
            if AptNo <> Apt."No." then
                Apt.Get(AptNo);
        end else
            Clear(Apt);
    end;
	
	local procedure GetMtWrk(MtWkCode: Code[10])
	begin
	    if not (MtWkCode = '') then begin
	        if MtWkCode <> MtWrk.Code then
	            MtWrk.Get(MtWkCode);
	    end else
	        Clear(MtWrk);
	end;

    local procedure GetAptSetup()
    begin
        if not AptSetupRead then
            AptSetup.Get();

        AptSetupRead := true;
        OnAfterGetAptSetup(Rec, AptSetup, CurrFieldNo);
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnAfterGetAptSetup(WrkOrdHeader: Record "FM Wrk. Ord. Header"; var AptSetup: Record "FM Apartment Setup"; CalledByFieldNo: Integer)
    begin
    end;
    
    
    [IntegrationEvent(false, false)]
    local procedure OnBeforeLookupCity(WrkOrdHeader: Record "FM Wrk. Ord. Header"; var PostCodeRec: Record "Post Code");
    begin
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnBeforeLookupPostCode(WrkOrdHeader: Record "FM Wrk. Ord. Header"; var PostCodeRec: Record "Post Code");
    begin
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateCity(WrkOrdHeader: Record "FM Wrk. Ord. Header"; var PostCodeRec: Record "Post Code");
    begin
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidatePostCode(WrkOrdHeader: Record "FM Wrk. Ord. Header"; var PostCodeRec: Record "Post Code");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateAptNoAfterInit(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; xWrkOrdHeader: Record "FM Wrk. Ord. Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckAptNo(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; xWrkOrdHeader: Record "FM Wrk. Ord. Header"; Apt: Record "FM Apartment")
    begin
    end;

    procedure WrkOrdLineExist(): Boolean
    begin
        WrkOrdLine.Reset();
        WrkOrdLine.SetRange("Document No.", "No.");
        exit(not WrkOrdLine.IsEmpty);
    end;
    

    [IntegrationEvent(false, false)]
    local procedure OnValidatePostingDateOnBeforeAssignDocumentDate(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var IsHandled: Boolean)
    begin
    end;

    local procedure GetPostingNoSeriesCode() PostingNos: Code[20]
    var
        IsHandled: Boolean;
    begin
        GetAptSetup();
        IsHandled := false;
        OnBeforeGetPostingNoSeriesCode(Rec, AptSetup, PostingNos, IsHandled);
        if IsHandled then
            exit;

        PostingNos := AptSetup."Posted Wrk. Ord. Nos.";

        OnAfterGetPostingNoSeriesCode(Rec, PostingNos);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPostingNoSeriesCode(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; AptSetup: Record "FM Apartment Setup"; var NoSeriesCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetPostingNoSeriesCode(WrkOrdHeader: Record "FM Wrk. Ord. Header"; var PostingNos: Code[20])
    begin
    end;
}
