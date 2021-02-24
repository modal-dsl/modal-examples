table 50006 "FM Wrk. Ord. Line"
{
	Caption = 'FM Wrk. Ord. Line';
	
    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "FM Wrk. Ord. Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Cost Type"; Enum "FM Cost Type")
        {
        	Caption = 'Cost Type';
        }
        field(4; Description; Text[50])
        {
        	Caption = 'Description';
        }
        field(5; Quantity; Decimal)
        {
        	Caption = 'Quantity';
        }
        field(6; Amount; Decimal)
        {
        	Caption = 'Amount';
        	AutoFormatType = 1;
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
        WrkOrdHeader: Record "FM Wrk. Ord. Header";
        AptCommentLine: Record "FM Apartment Comment Line";
        StatusCheckSuspended: Boolean;
        HideValidationDialog: Boolean;
        RenameNotAllowedErr: Label 'You cannot rename a %1.';

    trigger OnRename()
    begin
        Error(RenameNotAllowedErr, TableCaption);
    end;

    trigger OnDelete()
    begin
        AptCommentLine.SetRange("Document Type", AptCommentLine."Document Type"::"Work Order");
        AptCommentLine.SetRange("No.", "Document No.");
        AptCommentLine.SetRange("Line No.", "Line No.");
        AptCommentLine.DeleteAll();
    end;
	
    procedure TestStatusPlanning()
    begin
        GetWrkOrdHeader();
        OnBeforeTestStatusPlanning(Rec, WrkOrdHeader);

        if StatusCheckSuspended then
            exit;

        WrkOrdHeader.Testfield(Status, WrkOrdHeader.Status::Planning);

        OnAfterTestStatusPlanning(Rec, WrkOrdHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestStatusPlanning(var WrkOrdLine: Record "FM Wrk. Ord. Line"; var WrkOrdHeader: Record "FM Wrk. Ord. Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestStatusPlanning(var WrkOrdLine: Record "FM Wrk. Ord. Line"; var WrkOrdHeader: Record "FM Wrk. Ord. Header")
    begin
    end;

    procedure SuspendStatusCheck(Suspend: Boolean)
    begin
        StatusCheckSuspended := Suspend;
    end;

    procedure GetWrkOrdHeader()
    var
        IsHandled: Boolean;
    begin
        OnBeforeGetWrkOrdHeader(Rec, WrkOrdHeader, IsHandled);
        if IsHandled then
            exit;

        TestField("Document No.");
        if "Document No." <> WrkOrdHeader."No." then
            WrkOrdHeader.Get("Document No.");

        OnAfterGetWrkOrdHeader(Rec, WrkOrdHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetWrkOrdHeader(var WrkOrdLine: Record "FM Wrk. Ord. Line"; var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var IsHanded: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetWrkOrdHeader(var WrkOrdLine: Record "FM Wrk. Ord. Line"; var WrkOrdHeader: Record "FM Wrk. Ord. Header")
    begin
    end;

    procedure InitRecord()
    begin
        GetWrkOrdHeader;
		
		OnBeforeInitRecord(Rec, WrkOrdHeader);
		
        Init();
		
		OnAfterInitRecord(Rec, WrkOrdHeader);
    end;
    
    [IntegrationEvent(false, false)]
  	local procedure OnBeforeInitRecord(var WrkOrdLine: Record "FM Wrk. Ord. Line"; var WrkOrdHeader: Record "FM Wrk. Ord. Header")
    begin
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRecord(var WrkOrdLine: Record "FM Wrk. Ord. Line"; var WrkOrdHeader: Record "FM Wrk. Ord. Header")
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
        AptCommentLine: Record "FM Apartment Comment Line";
        AptCommentSheet: Page "FM Apartment Comment Sheet";
    begin
        TestField("Document No.");
        TestField("Line No.");
        AptCommentLine.SetRange("Document Type", AptCommentLine."Document Type"::"Work Order");
        AptCommentLine.SetRange("No.", "Document No.");
        AptCommentLine.SetRange("Document Line No.", "Line No.");
        AptCommentSheet.SetTableView(AptCommentLine);
        AptCommentSheet.RunModal;
    end;
}
