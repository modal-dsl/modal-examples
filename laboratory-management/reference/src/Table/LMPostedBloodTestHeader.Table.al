table 50044 "LM Posted Blood Test Header"
{
    Caption = 'Posted Blood Test Header';
    DataCaptionFields = "No.";
    LookupPageId = "LM Posted Blood Test";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Patient No."; Code[20])
        {
            Caption = 'Patient No.';
            TableRelation = "LM Patient";
        }
        field(3; Status; Enum "LM Blood Test Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        
        field(4; Comment; Boolean)
        {
            Caption = 'Comment';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = exist ("LM Patient Comment Line" where("No." = field("No."), "Document Line No." = const(0)));
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
            TableRelation = "LM Posted Blood Test Header";
        }
        field(15; "Pat. Name"; Text[100])
        {
        	Caption = 'Pat. Name';
        	
        }
        field(16; "Pat. Name 2"; Text[50])
        {
        	Caption = 'Pat. Name 2';
        }
        field(17; "Bld. Test No."; Code[20])
        {
        	Caption = 'Bld. Test No.';
        }
        field(18; "Bld. Test Nos."; Code[20])
        {
        	Caption = 'Bld. Test Nos.';
        	TableRelation = "No. Series".Code;
        }
        field(19; "User ID"; Code[50])
        {
        	Caption = 'User ID';
        	TableRelation = User."User Name";
        	ValidateTableRelation = false;
        }
        field(20; "Source Code"; Code[10])
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
        PatCommentLine.SetRange("Document Type", PatCommentLine."Document Type"::"Posted Blood Test");
        PatCommentLine.SetRange("No.", "No.");
        PatCommentLine.DeleteAll();
        
        PstdBldTestLine.DeleteAll();
    end;
    
    var
    	PatCommentLine: Record "LM Patient Comment Line";
    	PstdBldTestLine: Record "LM Posted Blood Test Line";
    
    procedure Navigate()
    var
    	NavigatePage: Page Navigate;
    begin
    	NavigatePage.SetDoc("Posting Date", "No.");
    	NavigatePage.SetRec(Rec);
    	NavigatePage.Run;
   	end;
   	
}
