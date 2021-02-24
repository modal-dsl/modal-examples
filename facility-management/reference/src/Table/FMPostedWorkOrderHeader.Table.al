table 50005 "FM Posted Work Order Header"
{
    Caption = 'Posted Work Order Header';
    DataCaptionFields = "No.";
    LookupPageId = "FM Posted Work Order";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Apartment No."; Code[20])
        {
            Caption = 'Apartment No.';
            TableRelation = "FM Apartment";
        }
        field(3; Status; Enum "FM Work Order Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        
        field(4; Comment; Boolean)
        {
            Caption = 'Comment';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = exist ("FM Apartment Comment Line" where("No." = field("No."), "Document Line No." = const(0)));
        }
        field(5; "No. Printed"; Integer)
        {
            Caption = 'No. Printed';
            Editable = false;
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(7; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(8; "Posting Description"; Text[100])
        {
            Caption = 'Posting Description';
        }
        field(9; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(10; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(11; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(12; "Posting No."; Code[20])
        {
            Caption = 'Posting No.';
        }
        field(13; "Posting No. Series"; Code[20])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
        }
        field(14; "Last Posting No."; Code[20])
        {
            Caption = 'Last Posting No.';
            Editable = false;
            TableRelation = "FM Posted Work Order Header";
        }
        field(15; "Mt. Wk. Code"; Code[10])
        {
        	Caption = 'Mt. Wk. Code';
        	TableRelation = "FM Maintenance Worker";
        }
        field(16; "Finish Until"; Date)
        {
        	Caption = 'Finish Until';
        }
        field(17; "Requested By"; Text[50])
        {
        	Caption = 'Requested By';
        }
        field(18; "Apt. Description"; Text[100])
        {
        	Caption = 'Apt. Description';
        	
        }
        field(19; "Apt. Description 2"; Text[50])
        {
        	Caption = 'Apt. Description 2';
        }
        field(20; "Apt. Address"; Text[100])
        {
        	Caption = 'Apt. Address';
        }
        field(21; "Apt. Address 2"; Text[50])
        {
        	Caption = 'Apt. Address 2';
        }
        field(22; "Apt. City"; Text[30])
        {
        	Caption = 'Apt. City';
        	TableRelation = if ("Apt. Country/Region Code" = const('')) "Post Code".City
        	else
        	if ("Apt. Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Apt. Country/Region Code"));
        	ValidateTableRelation = false;
        }
        field(23; "Apt. Country/Region Code"; Code[10])
        {
        	Caption = 'Apt. Country/Region Code';
        	TableRelation = "Country/Region";
        }
        field(24; "Apt. Post Code"; Code[20])
        {
        	Caption = 'Apt. Post Code';
        	TableRelation = if ("Apt. Country/Region Code" = const('')) "Post Code"
        	else
        	if ("Apt. Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Apt. Country/Region Code"));
        	ValidateTableRelation = false;
        }
        field(25; "Apt. County"; Text[30])
        {
        	CaptionClass = '5,1,' + "Apt. Country/Region Code";
        	Caption = 'Apt. County';
        }
        field(26; "Mt. Wrk. Name"; Text[100])
        {
        	Caption = 'Mt. Wrk. Name';
        	
        }
        field(27; "Mt. Wrk. Name 2"; Text[50])
        {
        	Caption = 'Mt. Wrk. Name 2';
        }
        field(28; "Wrk. Ord. No."; Code[20])
        {
        	Caption = 'Wrk. Ord. No.';
        }
        field(29; "Wrk. Ord. Nos."; Code[20])
        {
        	Caption = 'Wrk. Ord. Nos.';
        	TableRelation = "No. Series".Code;
        }
        field(30; "User ID"; Code[50])
        {
        	Caption = 'User ID';
        	TableRelation = User."User Name";
        	ValidateTableRelation = false;
        }
        field(31; "Source Code"; Code[10])
        {
        	Caption = 'Source Code';
        }
	}

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Posting Date") { }
    }
    
    trigger OnDelete()
    begin
        AptCommentLine.SetRange("Document Type", AptCommentLine."Document Type"::"Posted Work Order");
        AptCommentLine.SetRange("No.", "No.");
        AptCommentLine.DeleteAll();
        
        PstdWrkOrdLine.DeleteAll();
    end;
    
    var
    	AptCommentLine: Record "FM Apartment Comment Line";
    	PstdWrkOrdLine: Record "FM Posted Work Order Line";
    
    procedure Navigate()
    var
    	NavigatePage: Page Navigate;
    begin
    	NavigatePage.SetDoc("Posting Date", "No.");
    	NavigatePage.SetRec(Rec);
    	NavigatePage.Run;
   	end;
   	
}
