table 50041 "LM Patient Comment Line"
{
    Caption = 'Patient Comment Line';
    DrillDownPageID = "LM Patient Comment List";
    LookupPageID = "LM Patient Comment List";

    fields
    {
        field(1; "Document Type"; Enum "LM Patient Comment Document Type")
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
        PatCommentLine: Record "LM Patient Comment Line";
    begin
        PatCommentLine.SetRange("Document Type", "Document Type");
        PatCommentLine.SetRange("No.", "No.");
        PatCommentLine.SetRange("Document Line No.", "Document Line No.");
        PatCommentLine.SetRange(Date, WorkDate);
        if not PatCommentLine.FindFirst then
            Date := WorkDate;

        OnAfterSetUpNewLine(Rec, PatCommentLine);
    end;

    procedure CopyComments(FromDocumentType: Enum "LM Patient Comment Document Type"; ToDocumentType: Enum "LM Patient Comment Document Type"; FromNumber: Code[20]; ToNumber: Code[20])
    var
        PatCommentLine: Record "LM Patient Comment Line";
        PatCommentLine2: Record "LM Patient Comment Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyComments(PatCommentLine, ToDocumentType, IsHandled, FromDocumentType, FromNumber, ToNumber);
        if IsHandled then
            exit;

        PatCommentLine.SetRange("Document Type", FromDocumentType);
        PatCommentLine.SetRange("No.", FromNumber);
        if PatCommentLine.FindSet() then
            repeat
                PatCommentLine2 := PatCommentLine;
                PatCommentLine2."Document Type" := ToDocumentType;
                PatCommentLine2."No." := ToNumber;
                PatCommentLine2.Insert();
            until PatCommentLine.Next() = 0;
    end;

    procedure CopyLineComments(FromDocumentType: Enum "LM Patient Comment Document Type"; ToDocumentType: Enum "LM Patient Comment Document Type"; FromNumber: Code[20]; ToNumber: Code[20]; FromDocumentLineNo: Integer; ToDocumentLineNo: Integer)
    var
        PatCommentLineSource: Record "LM Patient Comment Line";
        PatCommentLineTarget: Record "LM Patient Comment Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyLineComments(
          PatCommentLineTarget, IsHandled, FromDocumentType, ToDocumentType, FromNumber, ToNumber, FromDocumentLineNo, ToDocumentLineNo);
        if IsHandled then
            exit;

        PatCommentLineSource.SetRange("Document Type", FromDocumentType);
        PatCommentLineSource.SetRange("No.", FromNumber);
        PatCommentLineSource.SetRange("Document Line No.", FromDocumentLineNo);
        if PatCommentLineSource.FindSet() then
            repeat
                PatCommentLineTarget := PatCommentLineSource;
                PatCommentLineTarget."Document Type" := ToDocumentType;
                PatCommentLineTarget."No." := ToNumber;
                PatCommentLineTarget."Document Line No." := ToDocumentLineNo;
                PatCommentLineTarget.Insert();
            until PatCommentLineSource.Next() = 0;
    end;

    procedure CopyHeaderComments(FromDocumentType: Enum "LM Patient Comment Document Type"; ToDocumentType: Enum "LM Patient Comment Document Type"; FromNumber: Code[20]; ToNumber: Code[20])
    var
        PatCommentLineSource: Record "LM Patient Comment Line";
        PatCommentLineTarget: Record "LM Patient Comment Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyHeaderComments(PatCommentLineTarget, IsHandled, FromDocumentType, ToDocumentType, FromNumber, ToNumber);
        if IsHandled then
            exit;

        PatCommentLineSource.SetRange("Document Type", FromDocumentType);
        PatCommentLineSource.SetRange("No.", FromNumber);
        PatCommentLineSource.SetRange("Document Line No.", 0);
        if PatCommentLineSource.FindSet() then
            repeat
                PatCommentLineTarget := PatCommentLineSource;
                PatCommentLineTarget."Document Type" := ToDocumentType;
                PatCommentLineTarget."No." := ToNumber;
                PatCommentLineTarget.Insert();
            until PatCommentLineSource.Next() = 0;
    end;

    procedure DeleteComments(DocType: Enum "LM Patient Comment Document Type"; DocNo: Code[20])
    begin
        SetRange("Document Type", DocType);
        SetRange("No.", DocNo);
        if not IsEmpty then
            DeleteAll();
    end;

    procedure ShowComments(DocType: Enum "LM Patient Comment Document Type"; DocNo: Code[20]; DocLineNo: Integer)
    var
        PatCommentSheet: Page "LM Patient Comment Sheet";
    begin
        SetRange("Document Type", DocType);
        SetRange("No.", DocNo);
        SetRange("Document Line No.", DocLineNo);
        Clear(PatCommentSheet);
        PatCommentSheet.SetTableView(Rec);
        PatCommentSheet.RunModal;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetUpNewLine(var PatCommentLineRec: Record "LM Patient Comment Line"; var PatCommentLineFilter: Record "LM Patient Comment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyComments(var PatCommentLine: Record "LM Patient Comment Line"; ToDocumentType: Enum "LM Patient Comment Document Type"; var IsHandled: Boolean; FromDocumentType: Enum "LM Patient Comment Document Type"; FromNumber: Code[20]; ToNumber: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyLineComments(var PatCommentLine: Record "LM Patient Comment Line"; var IsHandled: Boolean; FromDocumentType: Enum "LM Patient Comment Document Type"; ToDocumentType: Enum "LM Patient Comment Document Type"; FromNumber: Code[20]; ToNumber: Code[20]; FromDocumentLineNo: Integer; ToDocumentLine: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyHeaderComments(var PatCommentLine: Record "LM Patient Comment Line"; var IsHandled: Boolean; FromDocumentType: Enum "LM Patient Comment Document Type"; ToDocumentType: Enum "LM Patient Comment Document Type"; FromNumber: Code[20]; ToNumber: Code[20])
    begin
    end;
}
