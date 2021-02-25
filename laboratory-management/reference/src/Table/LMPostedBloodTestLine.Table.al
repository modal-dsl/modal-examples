table 50046 "LM Posted Blood Test Line"
{
	Caption = 'LM Posted Blood Test Line';
	
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
        PatCommentLine: Record "LM Patient Comment Line";

    trigger OnDelete()
    begin
        PatCommentLine.SetRange("Document Type", PatCommentLine."Document Type"::"Posted Blood Test");
        PatCommentLine.SetRange("No.", "Document No.");
        PatCommentLine.SetRange("Line No.", "Line No.");
        PatCommentLine.DeleteAll();
    end;
    
	procedure ShowLineComments()
	var
		PatCommentLine: Record "LM Patient Comment Line";
	begin
		PatCommentLine.ShowComments(PatCommentLine."Document Type"::"Posted Blood Test", "Document No.", "Line No.");
	end;
}
