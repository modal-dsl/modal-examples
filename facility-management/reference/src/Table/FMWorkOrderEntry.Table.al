table 50009 "FM Work Order Entry"
{
    Caption = 'Work Order Entry';
    DrillDownPageID = "FM Work Order Entries";
    LookupPageID = "FM Work Order Entries";

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
        field(7; "Apartment No."; Code[20])
        {
            Caption = 'Apartment No.';
            TableRelation = "FM Apartment";
        }
        field(8; "Work Order No."; Code[20])
        {
            Caption = 'Work Order No.';
        }
        field(9; "Mt. Wk. Code"; Code[10])
        {
        	Caption = 'Mt. Wk. Code';
        	TableRelation = "FM Maintenance Worker";
        }
        field(10; "Wrk. Ord. Requested By"; Text[50])
        {
        	Caption = 'Wrk. Ord. Requested By';
        }
        field(11; "Wrk. Ord. Cost Type"; Enum "FM Cost Type")
        {
        	Caption = 'Wrk. Ord. Cost Type';
        }
        field(12; "Wrk. Ord. Quantity"; Decimal)
        {
        	Caption = 'Wrk. Ord. Quantity';
        }
        field(13; "Wrk. Ord. Amount"; Decimal)
        {
        	Caption = 'Wrk. Ord. Amount';
        	AutoFormatType = 1;
        }
        field(14; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
        }
        field(15; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
            TableRelation = "Source Code";
        }
        field(16; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(17; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(18; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(19; "Last Modified DateTime"; DateTime)
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
        key(Key2; "Apartment No.", "Posting Date") {}
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

    procedure CopyFromAptJnlLine(AptJnlLine: Record "FM Apartment Journal Line")
    begin
        "Apartment No." := AptJnlLine."Apartment No.";
        "Posting Date" := AptJnlLine."Posting Date";
        "Document Date" := AptJnlLine."Document Date";
        "Document No." := AptJnlLine."Document No.";
        Description := AptJnlLine.Description;
        "Source No." := AptJnlLine."Source No.";
        "Journal Batch Name" := AptJnlLine."Journal Batch Name";
        "Source Code" := AptJnlLine."Source Code";
        "Reason Code" := AptJnlLine."Reason Code";
        "No. Series" := AptJnlLine."Posting No. Series";

        OnAfterCopyWrkOrdEntryFromAptJnlLine(Rec, AptJnlLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyWrkOrdEntryFromAptJnlLine(var WrkOrdEntry: Record "FM Work Order Entry"; var AptJnlLine: Record "FM Apartment Journal Line")
    begin
    end;
}
