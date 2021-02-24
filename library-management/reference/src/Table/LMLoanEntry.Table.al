table 50029 "LM Loan Entry"
{
    Caption = 'Loan Entry';
    DrillDownPageID = "LM Loan Entries";
    LookupPageID = "LM Loan Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(3; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
        }
		field(6; "Source No."; Code[20])
        {
            Caption = 'Source No.';
        }
        field(7; "Book No."; Code[20])
        {
            Caption = 'Book No.';
            TableRelation = "LM Book";
        }
        field(8; "Loan Order No."; Code[20])
        {
            Caption = 'Loan Order No.';
        }
        field(9; "Library User Code"; Code[10])
        {
        	Caption = 'Library User Code';
        	TableRelation = "LM Library User";
        }
        field(10; "Event Date"; Date)
        {
        	Caption = 'Event Date';
        }
        field(11; "Event Type"; Enum "LM Event Type")
        {
        	Caption = 'Event Type';
        }
        field(12; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
        }
        field(13; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
            TableRelation = "Source Code";
        }
        field(14; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(15; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(16; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(17; "Last Modified DateTime"; DateTime)
        {
            Caption = 'Last Modified DateTime';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Book No.", "Posting Date") {}
        key(Key3; "Document No.") {}
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Last Modified DateTime" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "Last Modified DateTime" := CurrentDateTime;
    end;

    trigger OnRename()
    begin
        "Last Modified DateTime" := CurrentDateTime;
    end;

    procedure GetLastEntryNo(): Integer;
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Entry No.")))
    end;

    procedure GetLastEntry(var LastEntryNo: Integer)
    var
        FindRecordManagement: Codeunit "Find Record Management";
        FieldNoValues: List of [Integer];
    begin
        FieldNoValues.Add(FieldNo("Entry No."));
        FindRecordManagement.GetLastEntryIntFieldValues(Rec, FieldNoValues);
        LastEntryNo := FieldNoValues.Get(1);
    end;

    procedure CopyFromBookJnlLine(BookJnlLine: Record "LM Book Journal Line")
    begin
        "Book No." := BookJnlLine."Book No.";
        "Posting Date" := BookJnlLine."Posting Date";
        "Document Date" := BookJnlLine."Document Date";
        "Document No." := BookJnlLine."Document No.";
        Description := BookJnlLine.Description;
        "Source No." := BookJnlLine."Source No.";
        "Journal Batch Name" := BookJnlLine."Journal Batch Name";
        "Source Code" := BookJnlLine."Source Code";
        "Reason Code" := BookJnlLine."Reason Code";
        "No. Series" := BookJnlLine."Posting No. Series";

        OnAfterCopyLoanEntryFromBookJnlLine(Rec, BookJnlLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyLoanEntryFromBookJnlLine(var LoanEntry: Record "LM Loan Entry"; var BookJnlLine: Record "LM Book Journal Line")
    begin
    end;
}
