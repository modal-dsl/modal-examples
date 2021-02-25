table 50047 "LM Patient Journal Line"
{
    Caption = 'Patient Journal Line';

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
        field(8; "Patient No."; Code[20])
        {
            Caption = 'Patient No.';
            TableRelation = "LM Patient";
        }
        field(9; "Blood Test No."; Code[20])
        {
            Caption = 'Blood Test No.';
        }
        field(10; Measurement; Decimal)
        {
        	Caption = 'Measurement';
        }
        field(11; Result; Option)
        {
        	Caption = 'Result';
        	OptionCaption = ',OK,Not OK';
        	OptionMembers = "","OK","Not OK";
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
        field(15; "Posting No. Series"; Code[10])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
        }
        field(16; "Last Modified DateTime"; DateTime)
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
        exit("Patient No." = '');
    end;

    procedure GetNewLineNo(TemplateName: Code[10]; BatchName: Code[10]): Integer
    var
        PatJnlLine: Record "LM Patient Journal Line";
    begin
        PatJnlLine.Validate("Journal Template Name", TemplateName);
        PatJnlLine.Validate("Journal Batch Name", BatchName);
        PatJnlLine.SetRange("Journal Template Name", TemplateName);
        PatJnlLine.SetRange("Journal Batch Name", BatchName);
        if PatJnlLine.FindLast then
            exit(PatJnlLine."Line No." + 10000);
        exit(10000);
    end;

    local procedure SetLastModifiedDateTime()
    var
        DotNet_DateTimeOffset: Codeunit DotNet_DateTimeOffset;
    begin
        "Last Modified DateTime" := DotNet_DateTimeOffset.ConvertToUtcDateTime(CurrentDateTime);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEmptyLine(PatJnlLine: Record "LM Patient Journal Line"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;
}
