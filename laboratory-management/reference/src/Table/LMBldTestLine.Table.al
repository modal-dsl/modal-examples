table 50045 "LM Bld. Test Line"
{
	Caption = 'LM Bld. Test Line';
	
    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "LM Bld. Test Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Description; Text[50])
        {
        	Caption = 'Description';
        }
        field(4; Measurement; Decimal)
        {
        	Caption = 'Measurement';
        }
        field(5; Result; Option)
        {
        	Caption = 'Result';
        	OptionCaption = ',OK,Not OK';
        	OptionMembers = "","OK","Not OK";
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
        BldTestHeader: Record "LM Bld. Test Header";
        PatCommentLine: Record "LM Patient Comment Line";
        StatusCheckSuspended: Boolean;
        HideValidationDialog: Boolean;
        RenameNotAllowedErr: Label 'You cannot rename a %1.';

    trigger OnRename()
    begin
        Error(RenameNotAllowedErr, TableCaption);
    end;

    trigger OnDelete()
    begin
        PatCommentLine.SetRange("Document Type", PatCommentLine."Document Type"::"Blood Test");
        PatCommentLine.SetRange("No.", "Document No.");
        PatCommentLine.SetRange("Line No.", "Line No.");
        PatCommentLine.DeleteAll();
    end;
	
    procedure TestStatusOpen()
    begin
        GetBldTestHeader();
        OnBeforeTestStatusOpen(Rec, BldTestHeader);

        if StatusCheckSuspended then
            exit;

        BldTestHeader.Testfield(Status, BldTestHeader.Status::Open);

        OnAfterTestStatusOpen(Rec, BldTestHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestStatusOpen(var BldTestLine: Record "LM Bld. Test Line"; var BldTestHeader: Record "LM Bld. Test Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestStatusOpen(var BldTestLine: Record "LM Bld. Test Line"; var BldTestHeader: Record "LM Bld. Test Header")
    begin
    end;

    procedure SuspendStatusCheck(Suspend: Boolean)
    begin
        StatusCheckSuspended := Suspend;
    end;

    procedure GetBldTestHeader()
    var
        IsHandled: Boolean;
    begin
        OnBeforeGetBldTestHeader(Rec, BldTestHeader, IsHandled);
        if IsHandled then
            exit;

        TestField("Document No.");
        if "Document No." <> BldTestHeader."No." then
            BldTestHeader.Get("Document No.");

        OnAfterGetBldTestHeader(Rec, BldTestHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetBldTestHeader(var BldTestLine: Record "LM Bld. Test Line"; var BldTestHeader: Record "LM Bld. Test Header"; var IsHanded: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetBldTestHeader(var BldTestLine: Record "LM Bld. Test Line"; var BldTestHeader: Record "LM Bld. Test Header")
    begin
    end;

    procedure InitRecord()
    begin
        GetBldTestHeader;
		
		OnBeforeInitRecord(Rec, BldTestHeader);
		
        Init();
		
		OnAfterInitRecord(Rec, BldTestHeader);
    end;
    
    [IntegrationEvent(false, false)]
  	local procedure OnBeforeInitRecord(var BldTestLine: Record "LM Bld. Test Line"; var BldTestHeader: Record "LM Bld. Test Header")
    begin
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRecord(var BldTestLine: Record "LM Bld. Test Line"; var BldTestHeader: Record "LM Bld. Test Header")
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
        PatCommentLine: Record "LM Patient Comment Line";
        PatCommentSheet: Page "LM Patient Comment Sheet";
    begin
        TestField("Document No.");
        TestField("Line No.");
        PatCommentLine.SetRange("Document Type", PatCommentLine."Document Type"::"Blood Test");
        PatCommentLine.SetRange("No.", "Document No.");
        PatCommentLine.SetRange("Document Line No.", "Line No.");
        PatCommentSheet.SetTableView(PatCommentLine);
        PatCommentSheet.RunModal;
    end;
}
