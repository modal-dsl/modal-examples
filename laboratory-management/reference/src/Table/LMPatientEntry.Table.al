table 50048 "LM Patient Entry"
{
    Caption = 'Patient Entry';
    DrillDownPageID = "LM Patient Entries";
    LookupPageID = "LM Patient Entries";

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
        field(7; "Patient No."; Code[20])
        {
            Caption = 'Patient No.';
            TableRelation = "LM Patient";
        }
        field(8; "Blood Test No."; Code[20])
        {
            Caption = 'Blood Test No.';
        }
        field(9; Measurement; Decimal)
        {
        	Caption = 'Measurement';
        }
        field(10; Result; Option)
        {
        	Caption = 'Result';
        	OptionCaption = ',OK,Not OK';
        	OptionMembers = "","OK","Not OK";
        }
        field(11; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
        }
        field(12; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
            TableRelation = "Source Code";
        }
        field(13; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(14; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(15; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(16; "Last Modified DateTime"; DateTime)
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
        key(Key2; "Patient No.", "Posting Date") {}
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

    procedure CopyFromPatJnlLine(PatJnlLine: Record "LM Patient Journal Line")
    begin
        "Patient No." := PatJnlLine."Patient No.";
        "Posting Date" := PatJnlLine."Posting Date";
        "Document Date" := PatJnlLine."Document Date";
        "Document No." := PatJnlLine."Document No.";
        Description := PatJnlLine.Description;
        "Source No." := PatJnlLine."Source No.";
        "Journal Batch Name" := PatJnlLine."Journal Batch Name";
        "Source Code" := PatJnlLine."Source Code";
        "Reason Code" := PatJnlLine."Reason Code";
        "No. Series" := PatJnlLine."Posting No. Series";

        OnAfterCopyPatEntryFromPatJnlLine(Rec, PatJnlLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPatEntryFromPatJnlLine(var PatEntry: Record "LM Patient Entry"; var PatJnlLine: Record "LM Patient Journal Line")
    begin
    end;
}
