table 50026 "LM Loan Ord. Line"
{
	Caption = 'LM Loan Ord. Line';
	
    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "LM Loan Ord. Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Event Date"; Date)
        {
        	Caption = 'Event Date';
        }
        field(4; "Event Type"; Enum "LM Event Type")
        {
        	Caption = 'Event Type';
        }
        field(5; Description; Text[50])
        {
        	Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        LoanOrdHeader: Record "LM Loan Ord. Header";
        BookCommentLine: Record "LM Book Comment Line";
        StatusCheckSuspended: Boolean;
        HideValidationDialog: Boolean;
        RenameNotAllowedErr: Label 'You cannot rename a %1.';

    trigger OnRename()
    begin
        Error(RenameNotAllowedErr, TableCaption);
    end;

    trigger OnDelete()
    begin
        BookCommentLine.SetRange("Document Type", BookCommentLine."Document Type"::"Loan Order");
        BookCommentLine.SetRange("No.", "Document No.");
        BookCommentLine.SetRange("Line No.", "Line No.");
        BookCommentLine.DeleteAll();
    end;
	
    procedure TestStatusOpen()
    begin
        GetLoanOrdHeader();
        OnBeforeTestStatusOpen(Rec, LoanOrdHeader);

        if StatusCheckSuspended then
            exit;

        LoanOrdHeader.Testfield(Status, LoanOrdHeader.Status::Open);

        OnAfterTestStatusOpen(Rec, LoanOrdHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestStatusOpen(var LoanOrdLine: Record "LM Loan Ord. Line"; var LoanOrdHeader: Record "LM Loan Ord. Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestStatusOpen(var LoanOrdLine: Record "LM Loan Ord. Line"; var LoanOrdHeader: Record "LM Loan Ord. Header")
    begin
    end;

    procedure SuspendStatusCheck(Suspend: Boolean)
    begin
        StatusCheckSuspended := Suspend;
    end;

    procedure GetLoanOrdHeader()
    var
        IsHandled: Boolean;
    begin
        OnBeforeGetLoanOrdHeader(Rec, LoanOrdHeader, IsHandled);
        if IsHandled then
            exit;

        TestField("Document No.");
        if "Document No." <> LoanOrdHeader."No." then
            LoanOrdHeader.Get("Document No.");

        OnAfterGetLoanOrdHeader(Rec, LoanOrdHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetLoanOrdHeader(var LoanOrdLine: Record "LM Loan Ord. Line"; var LoanOrdHeader: Record "LM Loan Ord. Header"; var IsHanded: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetLoanOrdHeader(var LoanOrdLine: Record "LM Loan Ord. Line"; var LoanOrdHeader: Record "LM Loan Ord. Header")
    begin
    end;

    procedure InitRecord()
    begin
        GetLoanOrdHeader;
		
		OnBeforeInitRecord(Rec, LoanOrdHeader);
		
        Init();
		
		OnAfterInitRecord(Rec, LoanOrdHeader);
    end;
    
    [IntegrationEvent(false, false)]
  	local procedure OnBeforeInitRecord(var LoanOrdLine: Record "LM Loan Ord. Line"; var LoanOrdHeader: Record "LM Loan Ord. Header")
    begin
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRecord(var LoanOrdLine: Record "LM Loan Ord. Line"; var LoanOrdHeader: Record "LM Loan Ord. Header")
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

    procedure ShowLineComments()
    var
        BookCommentLine: Record "LM Book Comment Line";
        BookCommentSheet: Page "LM Book Comment Sheet";
    begin
        TestField("Document No.");
        TestField("Line No.");
        BookCommentLine.SetRange("Document Type", BookCommentLine."Document Type"::"Loan Order");
        BookCommentLine.SetRange("No.", "Document No.");
        BookCommentLine.SetRange("Document Line No.", "Line No.");
        BookCommentSheet.SetTableView(BookCommentLine);
        BookCommentSheet.RunModal;
    end;
}
