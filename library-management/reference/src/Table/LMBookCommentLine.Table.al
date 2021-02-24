table 50021 "LM Book Comment Line"
{
    Caption = 'Book Comment Line';
    DrillDownPageID = "LM Book Comment List";
    LookupPageID = "LM Book Comment List";

    fields
    {
        field(1; "Document Type"; Enum "LM Book Comment Document Type")
        {
            Caption = 'Document Type';
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Date"; Date)
        {
            Caption = 'Date';
        }
        field(5; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(6; Comment; Text[80])
        {
            Caption = 'Comment';
        }
        field(7; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
        }
    }

    keys
    {
        key(Key1; "Document Type", "No.", "Document Line No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    procedure SetUpNewLine()
    var
        BookCommentLine: Record "LM Book Comment Line";
    begin
        BookCommentLine.SetRange("Document Type", "Document Type");
        BookCommentLine.SetRange("No.", "No.");
        BookCommentLine.SetRange("Document Line No.", "Document Line No.");
        BookCommentLine.SetRange(Date, WorkDate);
        if not BookCommentLine.FindFirst then
            Date := WorkDate;

        OnAfterSetUpNewLine(Rec, BookCommentLine);
    end;

    procedure CopyComments(FromDocumentType: Enum "LM Book Comment Document Type"; ToDocumentType: Enum "LM Book Comment Document Type"; FromNumber: Code[20]; ToNumber: Code[20])
    var
        BookCommentLine: Record "LM Book Comment Line";
        BookCommentLine2: Record "LM Book Comment Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyComments(BookCommentLine, ToDocumentType, IsHandled, FromDocumentType, FromNumber, ToNumber);
        if IsHandled then
            exit;

        BookCommentLine.SetRange("Document Type", FromDocumentType);
        BookCommentLine.SetRange("No.", FromNumber);
        if BookCommentLine.FindSet() then
            repeat
                BookCommentLine2 := BookCommentLine;
                BookCommentLine2."Document Type" := ToDocumentType;
                BookCommentLine2."No." := ToNumber;
                BookCommentLine2.Insert();
            until BookCommentLine.Next() = 0;
    end;

    procedure CopyLineComments(FromDocumentType: Enum "LM Book Comment Document Type"; ToDocumentType: Enum "LM Book Comment Document Type"; FromNumber: Code[20]; ToNumber: Code[20]; FromDocumentLineNo: Integer; ToDocumentLineNo: Integer)
    var
        BookCommentLineSource: Record "LM Book Comment Line";
        BookCommentLineTarget: Record "LM Book Comment Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyLineComments(
          BookCommentLineTarget, IsHandled, FromDocumentType, ToDocumentType, FromNumber, ToNumber, FromDocumentLineNo, ToDocumentLineNo);
        if IsHandled then
            exit;

        BookCommentLineSource.SetRange("Document Type", FromDocumentType);
        BookCommentLineSource.SetRange("No.", FromNumber);
        BookCommentLineSource.SetRange("Document Line No.", FromDocumentLineNo);
        if BookCommentLineSource.FindSet() then
            repeat
                BookCommentLineTarget := BookCommentLineSource;
                BookCommentLineTarget."Document Type" := ToDocumentType;
                BookCommentLineTarget."No." := ToNumber;
                BookCommentLineTarget."Document Line No." := ToDocumentLineNo;
                BookCommentLineTarget.Insert();
            until BookCommentLineSource.Next() = 0;
    end;

    procedure CopyHeaderComments(FromDocumentType: Enum "LM Book Comment Document Type"; ToDocumentType: Enum "LM Book Comment Document Type"; FromNumber: Code[20]; ToNumber: Code[20])
    var
        BookCommentLineSource: Record "LM Book Comment Line";
        BookCommentLineTarget: Record "LM Book Comment Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyHeaderComments(BookCommentLineTarget, IsHandled, FromDocumentType, ToDocumentType, FromNumber, ToNumber);
        if IsHandled then
            exit;

        BookCommentLineSource.SetRange("Document Type", FromDocumentType);
        BookCommentLineSource.SetRange("No.", FromNumber);
        BookCommentLineSource.SetRange("Document Line No.", 0);
        if BookCommentLineSource.FindSet() then
            repeat
                BookCommentLineTarget := BookCommentLineSource;
                BookCommentLineTarget."Document Type" := ToDocumentType;
                BookCommentLineTarget."No." := ToNumber;
                BookCommentLineTarget.Insert();
            until BookCommentLineSource.Next() = 0;
    end;

    procedure DeleteComments(DocType: Enum "LM Book Comment Document Type"; DocNo: Code[20])
    begin
        SetRange("Document Type", DocType);
        SetRange("No.", DocNo);
        if not IsEmpty then
            DeleteAll();
    end;

    procedure ShowComments(DocType: Enum "LM Book Comment Document Type"; DocNo: Code[20]; DocLineNo: Integer)
    var
        BookCommentSheet: Page "LM Book Comment Sheet";
    begin
        SetRange("Document Type", DocType);
        SetRange("No.", DocNo);
        SetRange("Document Line No.", DocLineNo);
        Clear(BookCommentSheet);
        BookCommentSheet.SetTableView(Rec);
        BookCommentSheet.RunModal;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetUpNewLine(var BookCommentLineRec: Record "LM Book Comment Line"; var BookCommentLineFilter: Record "LM Book Comment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyComments(var BookCommentLine: Record "LM Book Comment Line"; ToDocumentType: Enum "LM Book Comment Document Type"; var IsHandled: Boolean; FromDocumentType: Enum "LM Book Comment Document Type"; FromNumber: Code[20]; ToNumber: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyLineComments(var BookCommentLine: Record "LM Book Comment Line"; var IsHandled: Boolean; FromDocumentType: Enum "LM Book Comment Document Type"; ToDocumentType: Enum "LM Book Comment Document Type"; FromNumber: Code[20]; ToNumber: Code[20]; FromDocumentLineNo: Integer; ToDocumentLine: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyHeaderComments(var BookCommentLine: Record "LM Book Comment Line"; var IsHandled: Boolean; FromDocumentType: Enum "LM Book Comment Document Type"; ToDocumentType: Enum "LM Book Comment Document Type"; FromNumber: Code[20]; ToNumber: Code[20])
    begin
    end;
}
