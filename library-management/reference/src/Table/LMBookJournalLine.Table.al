table 50028 "LM Book Journal Line"
{
    Caption = 'Book Journal Line';

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
        field(8; "Book No."; Code[20])
        {
            Caption = 'Book No.';
            TableRelation = "LM Book";
        }
        field(9; "Loan Order No."; Code[20])
        {
            Caption = 'Loan Order No.';
        }
        field(10; "Library User Code"; Code[10])
        {
        	Caption = 'Library User Code';
        	TableRelation = "LM Library User";
        }
        field(11; "Event Date"; Date)
        {
        	Caption = 'Event Date';
        }
        field(12; "Event Type"; Enum "LM Event Type")
        {
        	Caption = 'Event Type';
        }
        field(13; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
        }
        field(14; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
            TableRelation = "Source Code";
        }
        field(15; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(16; "Posting No. Series"; Code[10])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
        }
        field(17; "Last Modified DateTime"; DateTime)
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
        exit("Book No." = '');
    end;

    procedure GetNewLineNo(TemplateName: Code[10]; BatchName: Code[10]): Integer
    var
        BookJnlLine: Record "LM Book Journal Line";
    begin
        BookJnlLine.Validate("Journal Template Name", TemplateName);
        BookJnlLine.Validate("Journal Batch Name", BatchName);
        BookJnlLine.SetRange("Journal Template Name", TemplateName);
        BookJnlLine.SetRange("Journal Batch Name", BatchName);
        if BookJnlLine.FindLast then
            exit(BookJnlLine."Line No." + 10000);
        exit(10000);
    end;

    local procedure SetLastModifiedDateTime()
    var
        DotNet_DateTimeOffset: Codeunit DotNet_DateTimeOffset;
    begin
        "Last Modified DateTime" := DotNet_DateTimeOffset.ConvertToUtcDateTime(CurrentDateTime);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEmptyLine(BookJnlLine: Record "LM Book Journal Line"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;
}
