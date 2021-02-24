table 50025 "LM Posted Loan Order Header"
{
    Caption = 'Posted Loan Order Header';
    DataCaptionFields = "No.";
    LookupPageId = "LM Posted Loan Order";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Book No."; Code[20])
        {
            Caption = 'Book No.';
            TableRelation = "LM Book";
        }
        field(3; Status; Enum "LM Loan Order Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        
        field(4; Comment; Boolean)
        {
            Caption = 'Comment';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = exist ("LM Book Comment Line" where("No." = field("No."), "Document Line No." = const(0)));
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
            TableRelation = "LM Posted Loan Order Header";
        }
        field(15; "Library User Code"; Code[10])
        {
        	Caption = 'Library User Code';
        	TableRelation = "LM Library User";
        }
        field(16; "Loan Start"; Date)
        {
        	Caption = 'Loan Start';
        }
        field(17; "Loan End"; Date)
        {
        	Caption = 'Loan End';
        }
        field(18; "Loan Ord. No."; Code[20])
        {
        	Caption = 'Loan Ord. No.';
        }
        field(19; "Loan Ord. Nos."; Code[20])
        {
        	Caption = 'Loan Ord. Nos.';
        	TableRelation = "No. Series".Code;
        }
        field(20; "User ID"; Code[50])
        {
        	Caption = 'User ID';
        	TableRelation = User."User Name";
        	ValidateTableRelation = false;
        }
        field(21; "Source Code"; Code[10])
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
        BookCommentLine.SetRange("Document Type", BookCommentLine."Document Type"::"Posted Loan Order");
        BookCommentLine.SetRange("No.", "No.");
        BookCommentLine.DeleteAll();
        
        PstdLoanOrdLine.DeleteAll();
    end;
    
    var
    	BookCommentLine: Record "LM Book Comment Line";
    	PstdLoanOrdLine: Record "LM Posted Loan Order Line";
    
    procedure Navigate()
    var
    	NavigatePage: Page Navigate;
    begin
    	NavigatePage.SetDoc("Posting Date", "No.");
    	NavigatePage.SetRec(Rec);
    	NavigatePage.Run;
   	end;
   	
}
