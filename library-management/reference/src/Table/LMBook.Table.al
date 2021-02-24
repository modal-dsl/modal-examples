table 50022 "LM Book"
{
	Caption = 'Book';
	DataCaptionFields = Description, "No.";
	DrillDownPageID = "LM Book List";
	LookupPageId = "LM Book List";
	
	fields
	{
		field(1; "No."; Code[20])
		{
			Caption = 'No.';
			
			trigger OnValidate()
			begin
				if "No." <> xRec."No." then begin
					GetBookSetup();
					NoSeriesMgt.TestManual(BookSetup."Book Nos.");
					"No. Series" := '';
				end;
			end;
		}
		field(2; "Description"; Text[100])
		{
			Caption = 'Description';
			
			trigger OnValidate()
			begin
				if ("Search Description" = UpperCase(xRec.Description)) or ("Search Description" = '') then
					"Search Description" := CopyStr(Description, 1, MaxStrLen("Search Description"));
			end;
		}
		field(3; "Search Description"; Code[100])
		{
			Caption = 'Search Description';
		}
		field(4; "Description 2"; Text[50])
		{
			Caption = 'Description 2';
		}
		field(5; "Book Type"; Enum "LM Book Type")
		{
			Caption = 'Book Type';
		}
		field(6; Author; Text[50])
		{
			Caption = 'Author';
		}
		field(7; Genre; Text[50])
		{
			Caption = 'Genre';
		}
		field(8; "Language Code"; Code[10])
		{
			Caption = 'Language Code';
			TableRelation = Language;
		}
		field(9; "Page Count"; Integer)
		{
			Caption = 'Page Count';
		}
		field(10; "Release Date"; Date)
		{
			Caption = 'Release Date';
		}
		field(11; Publisher; Text[50])
		{
			Caption = 'Publisher';
		}
		field(12; ISBN; Code[20])
		{
			Caption = 'ISBN';
		}
		field(13; Blocked; Boolean)
		{
			Caption = 'Blocked';
		}
		field(14; "Last Date Modified"; Date)
		{
			Caption = 'Last Date Modified';
			Editable = false;
		}
		field(15; "No. Series"; Code[20])
		{
			Caption = 'No. Series';
			Editable = false;
			TableRelation = "No. Series";
		}
		field(16; Comment; Boolean)
		{
			CalcFormula = Exist ("Comment Line" where("Table Name" = const(Book), "No." = field("No.")));
			Caption = 'Comment';
			Editable = false;
			FieldClass = FlowField;
		}
	}
	
	keys
	{
		key(Key1; "No.")
		{
			Clustered = true;
		}
		key(Key2; "Search Description") { }
	}
	
	fieldgroups
	{
		fieldgroup(DropDown; Description, "Description 2", "No.") { }
		fieldgroup(Brick; Description, "No.") { }
	}
	
	trigger OnInsert()
	begin
		if "No." = '' then begin
			TestBookNoSeries();
			NoSeriesMgt.InitSeries(BookSetup."Book Nos.", xRec."No. Series", 0D, "No.", "No. Series");
		end;
		
	end;
	
	trigger OnModify()
	begin
		"Last Date Modified" := Today;
	end;
	
	trigger OnDelete()
	begin
		CommentLine.SetRange("Table Name", CommentLine."Table Name"::Book);
		CommentLine.SetRange("No.", "No.");
		CommentLine.DeleteAll();
		
		LoanOrdHeader.SetCurrentKey("Book No.");
		LoanOrdHeader.SetRange("Book No.", "No.");
		IF NOT LoanOrdHeader.IsEmpty THEN
			Error(
				ExistingDocumentsErr,
				TableCaption, "No.", LoanOrdHeader.TableCaption);
	end;
	
	trigger OnRename()
	begin
		"Last Date Modified" := Today;
	end;
		
	var
		BookSetupRead: Boolean;
		BookSetup: Record "LM Book Setup";
		NoSeriesMgt: Codeunit NoSeriesManagement;
		CommentLine: Record "Comment Line";
		Book: Record "LM Book";
		LoanOrdHeader: Record "LM Loan Ord. Header";
		ExistingDocumentsErr: Label 'You cannot delete %1 %2 because there is at least one outstanding %3 for this Book.';
		
	procedure AssistEdit(OldBook: Record "LM Book"): Boolean
	begin
		Book := Rec;
		TestBookNoSeries();
		if NoSeriesMgt.SelectSeries(BookSetup."Book Nos.", OldBook."No. Series", Book."No. Series") then begin
			TestBookNoSeries();
			NoSeriesMgt.SetSeries(Book."No.");
			Rec := Book;
			exit(true);
		end;
	end;
	
	local procedure GetBookSetup()
	begin
		if not BookSetupRead then
			BookSetup.Get();
			
		BookSetupRead := true;
		
		OnAfterGetBookSetup(BookSetup);
	end;
	
	[IntegrationEvent(false, false)]
	local procedure OnAfterGetBookSetup(var BookSetup: Record "LM Book Setup")
	begin
	end;
	
	local procedure TestBookNoSeries()
	begin
		GetBookSetup();
		BookSetup.TestField("Book Nos.");
	end;
	
	procedure TestBlocked()
	begin
		TestField(Blocked, false);
	end;
}
