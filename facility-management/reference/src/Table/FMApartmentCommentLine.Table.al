table 50001 "FM Apartment Comment Line"
{
    Caption = 'Apartment Comment Line';
    DrillDownPageID = "FM Apartment Comment List";
    LookupPageID = "FM Apartment Comment List";

    fields
    {
        field(1; "Document Type"; Enum "FM Apartment Comment Document Type")
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
        AptCommentLine: Record "FM Apartment Comment Line";
    begin
        AptCommentLine.SetRange("Document Type", "Document Type");
        AptCommentLine.SetRange("No.", "No.");
        AptCommentLine.SetRange("Document Line No.", "Document Line No.");
        AptCommentLine.SetRange(Date, WorkDate);
        if not AptCommentLine.FindFirst then
            Date := WorkDate;

        OnAfterSetUpNewLine(Rec, AptCommentLine);
    end;

    procedure CopyComments(FromDocumentType: Enum "FM Apartment Comment Document Type"; ToDocumentType: Enum "FM Apartment Comment Document Type"; FromNumber: Code[20]; ToNumber: Code[20])
    var
        AptCommentLine: Record "FM Apartment Comment Line";
        AptCommentLine2: Record "FM Apartment Comment Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyComments(AptCommentLine, ToDocumentType, IsHandled, FromDocumentType, FromNumber, ToNumber);
        if IsHandled then
            exit;

        AptCommentLine.SetRange("Document Type", FromDocumentType);
        AptCommentLine.SetRange("No.", FromNumber);
        if AptCommentLine.FindSet() then
            repeat
                AptCommentLine2 := AptCommentLine;
                AptCommentLine2."Document Type" := ToDocumentType;
                AptCommentLine2."No." := ToNumber;
                AptCommentLine2.Insert();
            until AptCommentLine.Next() = 0;
    end;

    procedure CopyLineComments(FromDocumentType: Enum "FM Apartment Comment Document Type"; ToDocumentType: Enum "FM Apartment Comment Document Type"; FromNumber: Code[20]; ToNumber: Code[20]; FromDocumentLineNo: Integer; ToDocumentLineNo: Integer)
    var
        AptCommentLineSource: Record "FM Apartment Comment Line";
        AptCommentLineTarget: Record "FM Apartment Comment Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyLineComments(
          AptCommentLineTarget, IsHandled, FromDocumentType, ToDocumentType, FromNumber, ToNumber, FromDocumentLineNo, ToDocumentLineNo);
        if IsHandled then
            exit;

        AptCommentLineSource.SetRange("Document Type", FromDocumentType);
        AptCommentLineSource.SetRange("No.", FromNumber);
        AptCommentLineSource.SetRange("Document Line No.", FromDocumentLineNo);
        if AptCommentLineSource.FindSet() then
            repeat
                AptCommentLineTarget := AptCommentLineSource;
                AptCommentLineTarget."Document Type" := ToDocumentType;
                AptCommentLineTarget."No." := ToNumber;
                AptCommentLineTarget."Document Line No." := ToDocumentLineNo;
                AptCommentLineTarget.Insert();
            until AptCommentLineSource.Next() = 0;
    end;

    procedure CopyHeaderComments(FromDocumentType: Enum "FM Apartment Comment Document Type"; ToDocumentType: Enum "FM Apartment Comment Document Type"; FromNumber: Code[20]; ToNumber: Code[20])
    var
        AptCommentLineSource: Record "FM Apartment Comment Line";
        AptCommentLineTarget: Record "FM Apartment Comment Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyHeaderComments(AptCommentLineTarget, IsHandled, FromDocumentType, ToDocumentType, FromNumber, ToNumber);
        if IsHandled then
            exit;

        AptCommentLineSource.SetRange("Document Type", FromDocumentType);
        AptCommentLineSource.SetRange("No.", FromNumber);
        AptCommentLineSource.SetRange("Document Line No.", 0);
        if AptCommentLineSource.FindSet() then
            repeat
                AptCommentLineTarget := AptCommentLineSource;
                AptCommentLineTarget."Document Type" := ToDocumentType;
                AptCommentLineTarget."No." := ToNumber;
                AptCommentLineTarget.Insert();
            until AptCommentLineSource.Next() = 0;
    end;

    procedure DeleteComments(DocType: Enum "FM Apartment Comment Document Type"; DocNo: Code[20])
    begin
        SetRange("Document Type", DocType);
        SetRange("No.", DocNo);
        if not IsEmpty then
            DeleteAll();
    end;

    procedure ShowComments(DocType: Enum "FM Apartment Comment Document Type"; DocNo: Code[20]; DocLineNo: Integer)
    var
        AptCommentSheet: Page "FM Apartment Comment Sheet";
    begin
        SetRange("Document Type", DocType);
        SetRange("No.", DocNo);
        SetRange("Document Line No.", DocLineNo);
        Clear(AptCommentSheet);
        AptCommentSheet.SetTableView(Rec);
        AptCommentSheet.RunModal;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetUpNewLine(var AptCommentLineRec: Record "FM Apartment Comment Line"; var AptCommentLineFilter: Record "FM Apartment Comment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyComments(var AptCommentLine: Record "FM Apartment Comment Line"; ToDocumentType: Enum "FM Apartment Comment Document Type"; var IsHandled: Boolean; FromDocumentType: Enum "FM Apartment Comment Document Type"; FromNumber: Code[20]; ToNumber: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyLineComments(var AptCommentLine: Record "FM Apartment Comment Line"; var IsHandled: Boolean; FromDocumentType: Enum "FM Apartment Comment Document Type"; ToDocumentType: Enum "FM Apartment Comment Document Type"; FromNumber: Code[20]; ToNumber: Code[20]; FromDocumentLineNo: Integer; ToDocumentLine: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyHeaderComments(var AptCommentLine: Record "FM Apartment Comment Line"; var IsHandled: Boolean; FromDocumentType: Enum "FM Apartment Comment Document Type"; ToDocumentType: Enum "FM Apartment Comment Document Type"; FromNumber: Code[20]; ToNumber: Code[20])
    begin
    end;
}
