table 50042 "LM Patient"
{
	Caption = 'Patient';
	DataCaptionFields = Name, "No.";
	DrillDownPageID = "LM Patient List";
	LookupPageId = "LM Patient List";
	
	fields
	{
		field(1; "No."; Code[20])
		{
			Caption = 'No.';
			
			trigger OnValidate()
			begin
				if "No." <> xRec."No." then begin
					GetPatSetup();
					NoSeriesMgt.TestManual(PatSetup."Patient Nos.");
					"No. Series" := '';
				end;
			end;
		}
		field(2; "Name"; Text[100])
		{
			Caption = 'Name';
			
			trigger OnValidate()
			begin
				if ("Search Name" = UpperCase(xRec.Name)) or ("Search Name" = '') then
					"Search Name" := CopyStr(Name, 1, MaxStrLen("Search Name"));
			end;
		}
		field(3; "Search Name"; Code[100])
		{
			Caption = 'Search Name';
		}
		field(4; "Name 2"; Text[50])
		{
			Caption = 'Name 2';
		}
		field(5; Gender; Option)
		{
			Caption = 'Gender';
			OptionCaption = 'Female,Male';
			OptionMembers = "Female","Male";
		}
		field(6; Birthday; Date)
		{
			Caption = 'Birthday';
		}
		field(7; "Blood Type"; Option)
		{
			Caption = 'Blood Type';
			OptionCaption = 'A,B,AB,O';
			OptionMembers = "A","B","AB","O";
		}
		field(8; "Contact Person"; Text[50])
		{
			Caption = 'Contact Person';
		}
		field(9; "Phone No."; Text[30])
		{
			Caption = 'Phone No.';
			ExtendedDatatype = PhoneNo;
		}
		field(10; "Telex No."; Text[30])
		{
			Caption = 'Telex No.';
		}
		field(11; "Fax No."; Text[30])
		{
			Caption = 'Fax No.';
		}
		field(12; "Telex Answer Back"; Text[20])
		{
			Caption = 'Telex Answer Back';
		}
		field(13; "E-Mail"; Text[80])
		{
			Caption = 'E-Mail';
			ExtendedDatatype = EMail;
			
			trigger OnValidate()
			var
				MailManagement: Codeunit "Mail Management";
			begin
				MailManagement.ValidateEmailAddressField("E-Mail");
			end;
		}
		field(14; "Home Page"; Text[80])
		{
			Caption = 'Home Page';
			ExtendedDatatype = URL;
		}
		field(15; Blocked; Boolean)
		{
			Caption = 'Blocked';
		}
		field(16; "Last Date Modified"; Date)
		{
			Caption = 'Last Date Modified';
			Editable = false;
		}
		field(17; "No. Series"; Code[20])
		{
			Caption = 'No. Series';
			Editable = false;
			TableRelation = "No. Series";
		}
		field(18; Comment; Boolean)
		{
			CalcFormula = Exist ("Comment Line" where("Table Name" = const(Patient), "No." = field("No.")));
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
		key(Key2; "Search Name") { }
	}
	
	fieldgroups
	{
		fieldgroup(DropDown; Name, "Name 2", "No.") { }
		fieldgroup(Brick; Name, "No.") { }
	}
	
	trigger OnInsert()
	begin
		if "No." = '' then begin
			TestPatientNoSeries();
			NoSeriesMgt.InitSeries(PatSetup."Patient Nos.", xRec."No. Series", 0D, "No.", "No. Series");
		end;
		
	end;
	
	trigger OnModify()
	begin
		"Last Date Modified" := Today;
	end;
	
	trigger OnDelete()
	begin
		CommentLine.SetRange("Table Name", CommentLine."Table Name"::Patient);
		CommentLine.SetRange("No.", "No.");
		CommentLine.DeleteAll();
		
		BldTestHeader.SetCurrentKey("Patient No.");
		BldTestHeader.SetRange("Patient No.", "No.");
		IF NOT BldTestHeader.IsEmpty THEN
			Error(
				ExistingDocumentsErr,
				TableCaption, "No.", BldTestHeader.TableCaption);
	end;
	
	trigger OnRename()
	begin
		"Last Date Modified" := Today;
	end;
		
	var
		PatSetupRead: Boolean;
		PatSetup: Record "LM Patient Setup";
		NoSeriesMgt: Codeunit NoSeriesManagement;
		CommentLine: Record "Comment Line";
		Pat: Record "LM Patient";
		BldTestHeader: Record "LM Bld. Test Header";
		ExistingDocumentsErr: Label 'You cannot delete %1 %2 because there is at least one outstanding %3 for this Patient.';
		
	procedure AssistEdit(OldPat: Record "LM Patient"): Boolean
	begin
		Pat := Rec;
		TestPatientNoSeries();
		if NoSeriesMgt.SelectSeries(PatSetup."Patient Nos.", OldPat."No. Series", Pat."No. Series") then begin
			TestPatientNoSeries();
			NoSeriesMgt.SetSeries(Pat."No.");
			Rec := Pat;
			exit(true);
		end;
	end;
	
	local procedure GetPatSetup()
	begin
		if not PatSetupRead then
			PatSetup.Get();
			
		PatSetupRead := true;
		
		OnAfterGetPatSetup(PatSetup);
	end;
	
	[IntegrationEvent(false, false)]
	local procedure OnAfterGetPatSetup(var PatSetup: Record "LM Patient Setup")
	begin
	end;
	
	local procedure TestPatientNoSeries()
	begin
		GetPatSetup();
		PatSetup.TestField("Patient Nos.");
	end;
	
	procedure TestBlocked()
	begin
		TestField(Blocked, false);
	end;
}
