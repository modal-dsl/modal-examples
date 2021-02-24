table 50008 "FM Apartment Journal Line"
{
    Caption = 'Apartment Journal Line';

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';

            trigger OnValidate()
            begin
                TestField("Posting Date");
                Validate("Document Date", "Posting Date");
            end;
        }
        field(4; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
        }
        
        field(7; "Source No."; Code[20])
        {
            Caption = 'Source No.';
        }
        field(8; "Apartment No."; Code[20])
        {
            Caption = 'Apartment No.';
            TableRelation = "FM Apartment";
        }
        field(9; "Work Order No."; Code[20])
        {
            Caption = 'Work Order No.';
        }
        field(10; "Mt. Wk. Code"; Code[10])
        {
        	Caption = 'Mt. Wk. Code';
        	TableRelation = "FM Maintenance Worker";
        }
        field(11; "Wrk. Ord. Requested By"; Text[50])
        {
        	Caption = 'Wrk. Ord. Requested By';
        }
        field(12; "Wrk. Ord. Cost Type"; Enum "FM Cost Type")
        {
        	Caption = 'Wrk. Ord. Cost Type';
        }
        field(13; "Wrk. Ord. Quantity"; Decimal)
        {
        	Caption = 'Wrk. Ord. Quantity';
        }
        field(14; "Wrk. Ord. Amount"; Decimal)
        {
        	Caption = 'Wrk. Ord. Amount';
        	AutoFormatType = 1;
        }
        field(15; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
        }
        field(16; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
            TableRelation = "Source Code";
        }
        field(17; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(18; "Posting No. Series"; Code[10])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
        }
        field(19; "Last Modified DateTime"; DateTime)
        {
            Caption = 'Last Modified DateTime';
        }
    }

    keys
    {
        key(Key1; "Journal Batch Name", "Journal Template Name", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        SetLastModifiedDateTime;
    end;

    trigger OnModify()
    var
        IsHandled: Boolean;
    begin
        SetLastModifiedDateTime;
    end;

    procedure EmptyLine() Result: Boolean
    var
        IsHandled: Boolean;
    begin
        OnBeforeEmptyLine(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);
        exit("Apartment No." = '');
    end;

    procedure GetNewLineNo(TemplateName: Code[10]; BatchName: Code[10]): Integer
    var
        AptJnlLine: Record "FM Apartment Journal Line";
    begin
        AptJnlLine.Validate("Journal Template Name", TemplateName);
        AptJnlLine.Validate("Journal Batch Name", BatchName);
        AptJnlLine.SetRange("Journal Template Name", TemplateName);
        AptJnlLine.SetRange("Journal Batch Name", BatchName);
        if AptJnlLine.FindLast then
            exit(AptJnlLine."Line No." + 10000);
        exit(10000);
    end;

    local procedure SetLastModifiedDateTime()
    var
        DotNet_DateTimeOffset: Codeunit DotNet_DateTimeOffset;
    begin
        "Last Modified DateTime" := DotNet_DateTimeOffset.ConvertToUtcDateTime(CurrentDateTime);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEmptyLine(AptJnlLine: Record "FM Apartment Journal Line"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;
}
