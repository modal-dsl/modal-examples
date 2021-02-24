table 50003 "FM Maintenance Worker" {
	Caption = 'Maintenance Worker';
	DataCaptionFields = Name, Code;
	LookupPageId = "FM Maintenance Workers";
	
	fields
	{
		field(1; "Code"; Code[10])
		{
			Caption = 'Code';
			NotBlank = true;
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
		field(5; "Contact Person"; Text[50])
		{
			Caption = 'Contact Person';
		}
		field(6; "Phone No."; Text[30])
		{
			Caption = 'Phone No.';
			ExtendedDatatype = PhoneNo;
		}
		field(7; "Telex No."; Text[30])
		{
			Caption = 'Telex No.';
		}
		field(8; "Fax No."; Text[30])
		{
			Caption = 'Fax No.';
		}
		field(9; "Telex Answer Back"; Text[20])
		{
			Caption = 'Telex Answer Back';
		}
		field(10; "E-Mail"; Text[80])
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
		field(11; "Home Page"; Text[80])
		{
			Caption = 'Home Page';
			ExtendedDatatype = URL;
		}
		field(12; Blocked; Boolean)
		{
			Caption = 'Blocked';
		}
	}
	
	keys
	{
		key(Key1; "Code")
		{
			Clustered = true;
		}
		key(Key2; "Search Name") { }
	}
	
	fieldgroups
	{
		fieldgroup(DropDown; Name, "Name 2") { }
	}
	
	var
	
	procedure TestBlocked()
	begin
		TestField(Blocked, false);
	end;
}
