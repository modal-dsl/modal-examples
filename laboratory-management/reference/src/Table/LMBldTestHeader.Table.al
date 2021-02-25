table 50043 "LM Bld. Test Header"
{
    Caption = 'Blood Test Header';
    DataCaptionFields = "No.";
    LookupPageId = "LM Blood Test";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    GetPatSetup();
                    NoSeriesMgt.TestManual(PatSetup."Bld. Test Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Patient No."; Code[20])
        {
            Caption = 'Patient No.';
            TableRelation = "LM Patient";

            trigger OnValidate()
            begin
                if "No." = '' then
                    InitRecord;

                TestStatusOpen();
                if ("Patient No." <> xRec."Patient No.") and (xRec."Patient No." <> '') then begin
                    if GetHideValidationDialog or not GuiAllowed then
                        Confirmed := true
                    else
                        Confirmed := Confirm(ConfirmChangeQst, false, FieldCaption("Patient No."));

                    if Confirmed then begin
                        BldTestLine.SetRange("Document No.", "No.");
                        if "Patient No." = '' then begin
                            if not BldTestLine.IsEmpty then
                                Error(ExistingLinesErr, FieldCaption("Patient No."));
                            Init();
                            OnValidatePatNoAfterInit(Rec, xRec);
                            GetPatSetup();
                            "No. Series" := xRec."No. Series";
                            InitRecord();
                            InitNoSeries();
                            exit;
                        end;

                        BldTestLine.Reset();
                    end else begin
                        Rec := xRec;
                        exit;
                    end;
                end;

                GetPat("Patient No.");
                Pat.TestBlocked();
                OnAfterCheckPatNo(Rec, xRec, Pat);
                
                
                "Pat. Name 2" := Pat."Name 2";
                "Pat. Name" := Pat.Name;
            end;
        }
        field(3; Status; Enum "LM Blood Test Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        
        field(4; Comment; Boolean)
        {
            Caption = 'Comment';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = exist ("LM Patient Comment Line" where("No." = field("No."), "Document Line No." = const(0)));
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
                BldTestHeader := Rec;
                GetPatSetup();
                TestNoSeries();
                if NoSeriesMgt.LookupSeries(GetPostingNoSeriesCode, BldTestHeader."Posting No. Series") then
                    BldTestHeader.Validate("Posting No. Series");
                Rec := BldTestHeader;
            end;

            trigger OnValidate()
            begin
                if "Posting No. Series" <> '' then begin
                    GetPatSetup();
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
            TableRelation = "LM Posted Blood Test Header";
        }
        field(15; "Pat. Name"; Text[100])
        {
        	Caption = 'Pat. Name';
        	
        }
        field(16; "Pat. Name 2"; Text[50])
        {
        	Caption = 'Pat. Name 2';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Patient No.") { }
    }

    var
    	NoSeriesMgt: Codeunit NoSeriesManagement;
        PatSetup: Record "LM Patient Setup";
        PatSetupRead: Boolean;
        Pat: Record "LM Patient";
        BldTestHeader: Record "LM Bld. Test Header";
        BldTestLine: Record "LM Bld. Test Line";
        PatCommentLine: Record "LM Patient Comment Line";
        PostingDescrTxt: Label 'Bld. Test';
        Confirmed: Boolean;
        ConfirmChangeQst: Label 'Do you want to change %1?';
        SelectNoSeriesAllowed: Boolean;
        AlreadyExistsErr: Label 'The %1 %2 already exists.';
        HideValidationDialog: Boolean;
        StatusCheckSuspended: Boolean;
        ExistingLinesErr: Label 'You cannot reset %1 because the document still has one or more lines.';
        RenameNotAllowedErr: Label 'You cannot rename a %1.';
        NoSeriesDateOrderErr: Label 'You can not change the %1 field because %2 %3 has %4 = %5 and the document has already been assigned %6 %7.';

    trigger OnInsert()
    begin
        IF "No." = '' THEN BEGIN
            GetPatSetup;
            PatSetup.TESTFIELD("Bld. Test Nos.");
            NoSeriesMgt.InitSeries(PatSetup."Bld. Test Nos.", xRec."No. Series", "Posting Date", "No.", "No. Series");
        END;

        InitRecord;

        if GetFilterPatNo <> '' then
            Validate("Patient No.", GetFilterPatNo);
		
    end;

    trigger OnRename()
    begin
        Error(RenameNotAllowedErr, TableCaption);
    end;

    trigger OnDelete()
    begin
        PatCommentLine.SetRange("Document Type", PatCommentLine."Document Type"::"Blood Test");
        PatCommentLine.SetRange("No.", "No.");
        PatCommentLine.DeleteAll();
        
        BldTestLine.DeleteAll();
    end;

    local procedure GetFilterPatNo(): Code[20]
    begin
        if GetFilter("Patient No.") <> '' then
            if GetRangeMin("Patient No.") = GetRangeMax("Patient No.") then
                exit(GetRangeMax("Patient No."));
    end;

    procedure InitRecord()
    var
        IsHandled: Boolean;
    begin
        GetPatSetup();

        IsHandled := false;
        OnBeforeInitRecord(Rec, IsHandled, xRec);
        if not IsHandled then
            NoSeriesMgt.SetDefaultSeries("Posting No. Series", PatSetup."Posted Bld. Test Nos.");

        if "Posting Date" = 0D then
            "Posting Date" := WorkDate();

        "Document Date" := WorkDate();
        "Posting Description" := PostingDescrTxt + ' ' + "No.";

        OnAfterInitRecord(Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitRecord(var BldTestHeader: Record "LM Bld. Test Header"; var IsHandled: Boolean; xBldTestHeader: Record "LM Bld. Test Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRecord(var BldTestHeader: Record "LM Bld. Test Header")
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
    local procedure OnAfterInitNoSeries(var BldTestHeader: Record "LM Bld. Test Header"; xBldTestHeader: Record "LM Bld. Test Header")
    begin
    end;

    procedure AssistEdit(OldBldTestHeader: Record "LM Bld. Test Header"): Boolean
    var
        BldTestHeader2: Record "LM Bld. Test Header";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAssistEdit(Rec, OldBldTestHeader, IsHandled);
        if IsHandled then
            exit;

        BldTestHeader.Copy(Rec);
        GetPatSetup();
        TestNoSeries();
        if NoSeriesMgt.SelectSeries(BldTestHeader.GetNoSeriesCode(), OldBldTestHeader."No. Series", BldTestHeader."No. Series") then begin
            NoSeriesMgt.SetSeries(BldTestHeader."No.");
            if BldTestHeader2.Get(BldTestHeader."No.") then
                Error(AlreadyExistsErr, TableCaption, BldTestHeader."No.");
            Rec := BldTestHeader;
            exit(true);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAssistEdit(var BldTestHeader: Record "LM Bld. Test Header"; OldBldTestHeader: Record "LM Bld. Test Header"; var IsHandled: Boolean)
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
        GetPatSetup();
        
        IsHandled := false;
        OnBeforeGetNoSeriesCode(Rec, PatSetup, NoSeriesCode, IsHandled);
        if IsHandled then
            exit;

        NoSeriesCode := PatSetup."Bld. Test Nos.";

        OnAfterGetNoSeriesCode(Rec, PatSetup, NoSeriesCode);
        exit(NoSeriesMgt.GetNoSeriesWithCheck(NoSeriesCode, SelectNoSeriesAllowed, "No. Series"));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetNoSeriesCode(var BldTestHeader: Record "LM Bld. Test Header"; PatSetup: Record "LM Patient Setup"; var NoSeriesCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetNoSeriesCode(var BldTestHeader: Record "LM Bld. Test Header"; PatSetup: Record "LM Patient Setup"; var NoSeriesCode: Code[20])
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
        GetPatSetup();

        IsHandled := false;
        OnBeforeTestNoSeries(Rec, IsHandled);
        if IsHandled then
            exit;

        PatSetup.TestField("Bld. Test Nos.");

        OnAfterTestNoSeries(Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestNoSeries(var BldTestHeader: Record "LM Bld. Test Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestNoSeries(var BldTestHeader: Record "LM Bld. Test Header")
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

    procedure TestStatusOpen()
    begin
        OnBeforeTestStatusOpen(Rec);

        if StatusCheckSuspended then
            exit;

        TestField(Status, Status::Open);

        OnAfterTestStatusOpen(Rec);
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnBeforeTestStatusOpen(var BldTestHeader: Record "LM Bld. Test Header")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterTestStatusOpen(var BldTestHeader: Record "LM Bld. Test Header")
    begin
    end;

    procedure SuspendStatusCheck(Suspend: Boolean)
    begin
        StatusCheckSuspended := Suspend;
    end;

    local procedure GetPat(PatNo: Code[20])
    begin
        if not (PatNo = '') then begin
            if PatNo <> Pat."No." then
                Pat.Get(PatNo);
        end else
            Clear(Pat);
    end;

    local procedure GetPatSetup()
    begin
        if not PatSetupRead then
            PatSetup.Get();

        PatSetupRead := true;
        OnAfterGetPatSetup(Rec, PatSetup, CurrFieldNo);
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnAfterGetPatSetup(BldTestHeader: Record "LM Bld. Test Header"; var PatSetup: Record "LM Patient Setup"; CalledByFieldNo: Integer)
    begin
    end;
    

    [IntegrationEvent(false, false)]
    local procedure OnValidatePatNoAfterInit(var BldTestHeader: Record "LM Bld. Test Header"; xBldTestHeader: Record "LM Bld. Test Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckPatNo(var BldTestHeader: Record "LM Bld. Test Header"; xBldTestHeader: Record "LM Bld. Test Header"; Pat: Record "LM Patient")
    begin
    end;

    procedure BldTestLineExist(): Boolean
    begin
        BldTestLine.Reset();
        BldTestLine.SetRange("Document No.", "No.");
        exit(not BldTestLine.IsEmpty);
    end;
    

    [IntegrationEvent(false, false)]
    local procedure OnValidatePostingDateOnBeforeAssignDocumentDate(var BldTestHeader: Record "LM Bld. Test Header"; var IsHandled: Boolean)
    begin
    end;

    local procedure GetPostingNoSeriesCode() PostingNos: Code[20]
    var
        IsHandled: Boolean;
    begin
        GetPatSetup();
        IsHandled := false;
        OnBeforeGetPostingNoSeriesCode(Rec, PatSetup, PostingNos, IsHandled);
        if IsHandled then
            exit;

        PostingNos := PatSetup."Posted Bld. Test Nos.";

        OnAfterGetPostingNoSeriesCode(Rec, PostingNos);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPostingNoSeriesCode(var BldTestHeader: Record "LM Bld. Test Header"; PatSetup: Record "LM Patient Setup"; var NoSeriesCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetPostingNoSeriesCode(BldTestHeader: Record "LM Bld. Test Header"; var PostingNos: Code[20])
    begin
    end;
}
