table 50007 "FM Posted Work Order Line"
{
	Caption = 'FM Posted Work Order Line';
	
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
        AptCommentLine: Record "FM Apartment Comment Line";

    trigger OnDelete()
    begin
        AptCommentLine.SetRange("Document Type", AptCommentLine."Document Type"::"Posted Work Order");
        AptCommentLine.SetRange("No.", "Document No.");
        AptCommentLine.SetRange("Line No.", "Line No.");
        AptCommentLine.DeleteAll();
    end;
    
	procedure ShowLineComments()
	var
		AptCommentLine: Record "FM Apartment Comment Line";
	begin
		AptCommentLine.ShowComments(AptCommentLine."Document Type"::"Posted Work Order", "Document No.", "Line No.");
	end;
}
