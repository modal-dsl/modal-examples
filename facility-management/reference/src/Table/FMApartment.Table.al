table 50002 "FM Apartment"
{
	Caption = 'Apartment';
	DataCaptionFields = Description, "No.";
	DrillDownPageID = "FM Apartment List";
	LookupPageId = "FM Apartment List";
	
	fields
	{
		field(1; "No."; Code[20])
		{
			Caption = 'No.';
			
			trigger OnValidate()
			begin
				if "No." <> xRec."No." then begin
					GetAptSetup();
					NoSeriesMgt.TestManual(AptSetup."Apartment Nos.");
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
		field(5; "Address"; Text[100])
		{
			Caption = 'Address';
		}
		field(6; "Address 2"; Text[50])
		{
			Caption = 'Address 2';
		}
		field(7; "City"; Text[30])
		{
			Caption = 'City';
			TableRelation = if ("Country/Region Code" = const('')) "Post Code".City
			else
			if ("Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Country/Region Code"));
			ValidateTableRelation = false;
			
			trigger OnLookup()
			begin
				OnBeforeLookupCity(Rec, PostCode);
				
				PostCode.LookupPostCode("City", "Post Code", "County", "Country/Region Code");
			end;
			
			trigger OnValidate()
			begin
			OnBeforeValidateCity(Rec, PostCode);
			
			PostCode.ValidateCity("City", "Post Code", "County", "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
			end;
		}
		field(8; "Country/Region Code"; Code[10])
		{
			Caption = 'Country/Region Code';
			TableRelation = "Country/Region";
			
			trigger OnValidate()
			begin
				PostCode.CheckClearPostCodeCityCounty("City", "Post Code", "County", "Country/Region Code", xRec."Country/Region Code");
			end;
		}
		field(9; "Post Code"; Code[20])
		{
			Caption = 'Post Code';
			TableRelation = if ("Country/Region Code" = const('')) "Post Code"
			else
			if ("Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Country/Region Code"));
			ValidateTableRelation = false;
			
			trigger OnLookup()
			begin
				OnBeforeLookupPostCode(Rec, PostCode);
				
				PostCode.LookupPostCode("City", "Post Code", "County", "Country/Region Code");
			end;
			
			trigger OnValidate()
			begin
				OnBeforeValidatePostCode(Rec, PostCode);
				
				PostCode.ValidatePostCode("City", "Post Code", "County", "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
			end;
		}
		field(10; "County"; Text[30])
		{
			CaptionClass = '5,1,' + "Country/Region Code";
			Caption = 'County';
		}
		field(11; Floor; Text[50])
		{
			Caption = 'Floor';
		}
		field(12; Type; Enum "FM Type")
		{
			Caption = 'Type';
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
			CalcFormula = Exist ("Comment Line" where("Table Name" = const(Apartment), "No." = field("No.")));
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
			TestApartmentNoSeries();
			NoSeriesMgt.InitSeries(AptSetup."Apartment Nos.", xRec."No. Series", 0D, "No.", "No. Series");
		end;
		
	end;
	
	trigger OnModify()
	begin
		"Last Date Modified" := Today;
	end;
	
	trigger OnDelete()
	begin
		CommentLine.SetRange("Table Name", CommentLine."Table Name"::Apartment);
		CommentLine.SetRange("No.", "No.");
		CommentLine.DeleteAll();
		
		WrkOrdHeader.SetCurrentKey("Apartment No.");
		WrkOrdHeader.SetRange("Apartment No.", "No.");
		IF NOT WrkOrdHeader.IsEmpty THEN
			Error(
				ExistingDocumentsErr,
				TableCaption, "No.", WrkOrdHeader.TableCaption);
	end;
	
	trigger OnRename()
	begin
		"Last Date Modified" := Today;
	end;
		
	var
		AptSetupRead: Boolean;
		AptSetup: Record "FM Apartment Setup";
		NoSeriesMgt: Codeunit NoSeriesManagement;
		CommentLine: Record "Comment Line";
		Apt: Record "FM Apartment";
		WrkOrdHeader: Record "FM Wrk. Ord. Header";
		ExistingDocumentsErr: Label 'You cannot delete %1 %2 because there is at least one outstanding %3 for this Apartment.';
		PostCode: Record "Post Code";
		
	procedure AssistEdit(OldApt: Record "FM Apartment"): Boolean
	begin
		Apt := Rec;
		TestApartmentNoSeries();
		if NoSeriesMgt.SelectSeries(AptSetup."Apartment Nos.", OldApt."No. Series", Apt."No. Series") then begin
			TestApartmentNoSeries();
			NoSeriesMgt.SetSeries(Apt."No.");
			Rec := Apt;
			exit(true);
		end;
	end;
	
	local procedure GetAptSetup()
	begin
		if not AptSetupRead then
			AptSetup.Get();
			
		AptSetupRead := true;
		
		OnAfterGetAptSetup(AptSetup);
	end;
	
	[IntegrationEvent(false, false)]
	local procedure OnAfterGetAptSetup(var AptSetup: Record "FM Apartment Setup")
	begin
	end;
	
	local procedure TestApartmentNoSeries()
	begin
		GetAptSetup();
		AptSetup.TestField("Apartment Nos.");
	end;
	
	procedure TestBlocked()
	begin
		TestField(Blocked, false);
	end;
	
	[IntegrationEvent(false, false)]
	local procedure OnBeforeLookupCity(Apt: Record "FM Apartment"; var PostCodeRec: Record "Post Code");
	begin
	end;
	
	[IntegrationEvent(false, false)]
	local procedure OnBeforeLookupPostCode(Apt: Record "FM Apartment"; var PostCodeRec: Record "Post Code");
	begin
	end;
	
	[IntegrationEvent(false, false)]
	local procedure OnBeforeValidateCity(Apt: Record "FM Apartment"; var PostCodeRec: Record "Post Code");
	begin
	end;
	
	[IntegrationEvent(false, false)]
	local procedure OnBeforeValidatePostCode(Apt: Record "FM Apartment"; var PostCodeRec: Record "Post Code");
	begin
	end;
}
