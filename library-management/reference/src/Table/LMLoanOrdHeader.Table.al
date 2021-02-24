table 50024 "LM Loan Ord. Header"
{
    Caption = 'Loan Order Header';
    DataCaptionFields = "No.";
    LookupPageId = "LM Loan Order";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    GetBookSetup();
                    NoSeriesMgt.TestManual(BookSetup."Loan Ord. Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Book No."; Code[20])
        {
            Caption = 'Book No.';
            TableRelation = "LM Book";

            trigger OnValidate()
            begin
                if "No." = '' then
                    InitRecord;

                TestStatusOpen();
                if ("Book No." <> xRec."Book No.") and (xRec."Book No." <> '') then begin
                    if GetHideValidationDialog or not GuiAllowed then
                        Confirmed := true
                    else
                        Confirmed := Confirm(ConfirmChangeQst, false, FieldCaption("Book No."));

                    if Confirmed then begin
                        LoanOrdLine.SetRange("Document No.", "No.");
                        if "Book No." = '' then begin
                            if not LoanOrdLine.IsEmpty then
                                Error(ExistingLinesErr, FieldCaption("Book No."));
                            Init();
                            OnValidateBookNoAfterInit(Rec, xRec);
                            GetBookSetup();
                            "No. Series" := xRec."No. Series";
                            InitRecord();
                            InitNoSeries();
                            exit;
                        end;

                        LoanOrdLine.Reset();
                    end else begin
                        Rec := xRec;
                        exit;
                    end;
                end;

                GetBook("Book No.");
                Book.TestBlocked();
                OnAfterCheckBookNo(Rec, xRec, Book);
                
            end;
        }
        field(3; Status; Enum "LM Loan Order Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        
        field(4; Comment; Boolean)
        {
            Caption = 'Comment';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = exist ("LM Book Comment Line" where("No." = field("No."), "Document Line No." = const(0)));
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
                LoanOrdHeader := Rec;
                GetBookSetup();
                TestNoSeries();
                if NoSeriesMgt.LookupSeries(GetPostingNoSeriesCode, LoanOrdHeader."Posting No. Series") then
                    LoanOrdHeader.Validate("Posting No. Series");
                Rec := LoanOrdHeader;
            end;

            trigger OnValidate()
            begin
                if "Posting No. Series" <> '' then begin
                    GetBookSetup();
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
            TableRelation = "LM Posted Loan Order Header";
        }
        field(15; "Library User Code"; Code[10])
        {
        	Caption = 'Library User Code';
        	TableRelation = "LM Library User";
        	
        	trigger OnValidate()
        	begin
        		TestStatusOpen();
        		if ("Library User Code" <> xRec."Library User Code") and (xRec."Library User Code" <> '') then begin
        			if GetHideValidationDialog or not GuiAllowed then
        				Confirmed := true
        			else
        				Confirmed := Confirm(ConfirmChangeQst, false, FieldCaption("Library User Code"));
        			
        			if Confirmed then begin
        				if "Library User Code" = '' then
        					exit;
        			end else begin
        				Rec := xRec;
        				exit;
        			end;
        		end;
        		
        		If "Library User Code" = '' then
        			LibUser.Init()
        		else begin
        			GetLibUser("Library User Code");
        			LibUser.TestBlocked;
        		end;
        		
        	end;
        }
        field(16; "Loan Start"; Date)
        {
        	Caption = 'Loan Start';
        }
        field(17; "Loan End"; Date)
        {
        	Caption = 'Loan End';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Book No.") { }
    }

    var
    	NoSeriesMgt: Codeunit NoSeriesManagement;
        BookSetup: Record "LM Book Setup";
        BookSetupRead: Boolean;
        Book: Record "LM Book";
        LibUser: Record "LM Library User";
        LoanOrdHeader: Record "LM Loan Ord. Header";
        LoanOrdLine: Record "LM Loan Ord. Line";
        BookCommentLine: Record "LM Book Comment Line";
        PostingDescrTxt: Label 'Loan Ord.';
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
            GetBookSetup;
            BookSetup.TESTFIELD("Loan Ord. Nos.");
            NoSeriesMgt.InitSeries(BookSetup."Loan Ord. Nos.", xRec."No. Series", "Posting Date", "No.", "No. Series");
        END;

        InitRecord;

        if GetFilterBookNo <> '' then
            Validate("Book No.", GetFilterBookNo);
		
		if GetFilterLibUserCode <> '' then
			Validate("Library User Code", GetFilterLibUserCode);
    end;

    trigger OnRename()
    begin
        Error(RenameNotAllowedErr, TableCaption);
    end;

    trigger OnDelete()
    begin
        BookCommentLine.SetRange("Document Type", BookCommentLine."Document Type"::"Loan Order");
        BookCommentLine.SetRange("No.", "No.");
        BookCommentLine.DeleteAll();
        
        LoanOrdLine.DeleteAll();
    end;

    local procedure GetFilterBookNo(): Code[20]
    begin
        if GetFilter("Book No.") <> '' then
            if GetRangeMin("Book No.") = GetRangeMax("Book No.") then
                exit(GetRangeMax("Book No."));
    end;
	
	local procedure GetFilterLibUserCode(): Code[20]
		begin
			if GetFilter("Library User Code") <> '' then
				if GetRangeMin("Library User Code") = GetRangeMax("Library User Code") then
					exit(GetRangeMax("Library User Code"));
		end;

    procedure InitRecord()
    var
        IsHandled: Boolean;
    begin
        GetBookSetup();

        IsHandled := false;
        OnBeforeInitRecord(Rec, IsHandled, xRec);
        if not IsHandled then
            NoSeriesMgt.SetDefaultSeries("Posting No. Series", BookSetup."Posted Loan Ord. Nos.");

        if "Posting Date" = 0D then
            "Posting Date" := WorkDate();

        "Document Date" := WorkDate();
        "Posting Description" := PostingDescrTxt + ' ' + "No.";

        OnAfterInitRecord(Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitRecord(var LoanOrdHeader: Record "LM Loan Ord. Header"; var IsHandled: Boolean; xLoanOrdHeader: Record "LM Loan Ord. Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRecord(var LoanOrdHeader: Record "LM Loan Ord. Header")
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
    local procedure OnAfterInitNoSeries(var LoanOrdHeader: Record "LM Loan Ord. Header"; xLoanOrdHeader: Record "LM Loan Ord. Header")
    begin
    end;

    procedure AssistEdit(OldLoanOrdHeader: Record "LM Loan Ord. Header"): Boolean
    var
        LoanOrdHeader2: Record "LM Loan Ord. Header";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAssistEdit(Rec, OldLoanOrdHeader, IsHandled);
        if IsHandled then
            exit;

        LoanOrdHeader.Copy(Rec);
        GetBookSetup();
        TestNoSeries();
        if NoSeriesMgt.SelectSeries(LoanOrdHeader.GetNoSeriesCode(), OldLoanOrdHeader."No. Series", LoanOrdHeader."No. Series") then begin
            NoSeriesMgt.SetSeries(LoanOrdHeader."No.");
            if LoanOrdHeader2.Get(LoanOrdHeader."No.") then
                Error(AlreadyExistsErr, TableCaption, LoanOrdHeader."No.");
            Rec := LoanOrdHeader;
            exit(true);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAssistEdit(var LoanOrdHeader: Record "LM Loan Ord. Header"; OldLoanOrdHeader: Record "LM Loan Ord. Header"; var IsHandled: Boolean)
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
        GetBookSetup();
        
        IsHandled := false;
        OnBeforeGetNoSeriesCode(Rec, BookSetup, NoSeriesCode, IsHandled);
        if IsHandled then
            exit;

        NoSeriesCode := BookSetup."Loan Ord. Nos.";

        OnAfterGetNoSeriesCode(Rec, BookSetup, NoSeriesCode);
        exit(NoSeriesMgt.GetNoSeriesWithCheck(NoSeriesCode, SelectNoSeriesAllowed, "No. Series"));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetNoSeriesCode(var LoanOrdHeader: Record "LM Loan Ord. Header"; BookSetup: Record "LM Book Setup"; var NoSeriesCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetNoSeriesCode(var LoanOrdHeader: Record "LM Loan Ord. Header"; BookSetup: Record "LM Book Setup"; var NoSeriesCode: Code[20])
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
        GetBookSetup();

        IsHandled := false;
        OnBeforeTestNoSeries(Rec, IsHandled);
        if IsHandled then
            exit;

        BookSetup.TestField("Loan Ord. Nos.");

        OnAfterTestNoSeries(Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestNoSeries(var LoanOrdHeader: Record "LM Loan Ord. Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestNoSeries(var LoanOrdHeader: Record "LM Loan Ord. Header")
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
    local procedure OnBeforeTestStatusOpen(var LoanOrdHeader: Record "LM Loan Ord. Header")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterTestStatusOpen(var LoanOrdHeader: Record "LM Loan Ord. Header")
    begin
    end;

    procedure SuspendStatusCheck(Suspend: Boolean)
    begin
        StatusCheckSuspended := Suspend;
    end;

    local procedure GetBook(BookNo: Code[20])
    begin
        if not (BookNo = '') then begin
            if BookNo <> Book."No." then
                Book.Get(BookNo);
        end else
            Clear(Book);
    end;
	
	local procedure GetLibUser(LibraryUserCode: Code[10])
	begin
	    if not (LibraryUserCode = '') then begin
	        if LibraryUserCode <> LibUser.Code then
	            LibUser.Get(LibraryUserCode);
	    end else
	        Clear(LibUser);
	end;

    local procedure GetBookSetup()
    begin
        if not BookSetupRead then
            BookSetup.Get();

        BookSetupRead := true;
        OnAfterGetBookSetup(Rec, BookSetup, CurrFieldNo);
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnAfterGetBookSetup(LoanOrdHeader: Record "LM Loan Ord. Header"; var BookSetup: Record "LM Book Setup"; CalledByFieldNo: Integer)
    begin
    end;
    

    [IntegrationEvent(false, false)]
    local procedure OnValidateBookNoAfterInit(var LoanOrdHeader: Record "LM Loan Ord. Header"; xLoanOrdHeader: Record "LM Loan Ord. Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckBookNo(var LoanOrdHeader: Record "LM Loan Ord. Header"; xLoanOrdHeader: Record "LM Loan Ord. Header"; Book: Record "LM Book")
    begin
    end;

    procedure LoanOrdLineExist(): Boolean
    begin
        LoanOrdLine.Reset();
        LoanOrdLine.SetRange("Document No.", "No.");
        exit(not LoanOrdLine.IsEmpty);
    end;
    

    [IntegrationEvent(false, false)]
    local procedure OnValidatePostingDateOnBeforeAssignDocumentDate(var LoanOrdHeader: Record "LM Loan Ord. Header"; var IsHandled: Boolean)
    begin
    end;

    local procedure GetPostingNoSeriesCode() PostingNos: Code[20]
    var
        IsHandled: Boolean;
    begin
        GetBookSetup();
        IsHandled := false;
        OnBeforeGetPostingNoSeriesCode(Rec, BookSetup, PostingNos, IsHandled);
        if IsHandled then
            exit;

        PostingNos := BookSetup."Posted Loan Ord. Nos.";

        OnAfterGetPostingNoSeriesCode(Rec, PostingNos);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPostingNoSeriesCode(var LoanOrdHeader: Record "LM Loan Ord. Header"; BookSetup: Record "LM Book Setup"; var NoSeriesCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetPostingNoSeriesCode(LoanOrdHeader: Record "LM Loan Ord. Header"; var PostingNos: Code[20])
    begin
    end;
}
