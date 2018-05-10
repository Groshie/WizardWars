; ### THE SPELL PROJECT ###
; # Made by Groshie, just for fun and to learn a bit more!
; ### VARIABLES AND LISTS ###
; Wizard_Count := 3 ; <--- Set this variable to add or remove wizards from the duel! (Only used for testing without GUI)
Living := 0 <--- Is set at the end to check how many wizards are still alive
Names := ["Henry", "Dyne", "Radcally", "Dambledeure", "Gondelf", "Batface", "Natso", "Harry", "Arwun", "Pulgera", "Almanster", "Kholban", "Mistrea", "The Lady"] ; <--- Add or remove wizard names from this list!
Dead := [] ; <--- This is where dead wizards go... In theory...


; ### SPELL SETUP ###
Magic_Missile := new Spell("Magic Missile", "Arcane", 10, 5)
Lightning_Bolt := new Spell("Lightning Bolt", "Electricity", 25, 15)
Fireball := new Spell("Fireball", "Fire", 25, 20) 
Cone_of_Cold := new Spell("Cone of Cold", "Cold", 45, 40)
Wail_Banshee := new Spell("Wail of the Banshee", "Necrotic", 90, 85)
Spells := [Magic_Missile, Lightning_Bolt, Fireball, Cone_of_Cold, Wail_Banshee] ; <--- Add spell objects (not literal spellnames) here if you create more spells!


;### CLASSES AND FUNCTIONS ###
class Character
{
	__new(name:="John Doe")
	{
		this.Name := name
		this.Level := this.Rand(1, 20)
		this.Maximum_HP := this.Rand(1, 100) * this.Level
		this.Maximum_Mana := this.Rand(1, 100) * this.Level
		this.Current_HP := this.Maximum_HP
		this.Current_Mana := round(this.Maximum_Mana * this.Rand(0.01, 1))
	}
	
	Rand(x, y)
	{
		random, rand, x, y
		return rand
	}
}

class Spell
{
	__new(name:="Undefined", element:="Null", power:=0, cost:=0)
	{
		this.Name := name
		this.Element := element
		this.Power := power
		this.Cost := cost
		; Msgbox % "This is the spell " this.Name "`r`nIt has the element: " this.Element "`r`nIt has the base power: " this.Power " power`r`nThe base cost is: " this.Cost " mana"
	}
}

class Cast
{
	__new(spell:="None", character:="None", target:="None")
	{
		If (spell = "None")
			Msgbox No spell selected!
		Else
		{
			this.Name := spell.Name
			this.Power := spell.Power
			this.Cost := spell.Cost
			this.Power_Multiple := character.Level * (1 * (1 + (1 - (character.Current_Mana / character.Maximum_Mana))))
			this.Mana_Cost_Multiplier := 1 * (1 + (this.Power / character.Current_Mana))
			Msgbox % character.Name " is casting " this.Name " at " target.Name ", at power level (damage): " round(this.Power * this.Power_Multiple) ". It cost " character.Name " " round(this.Cost * this.Mana_Cost_Multiplier) " mana.`r`n`r`nTheir current mana is now: " round(character.Current_Mana - (this.Cost * this.Mana_Cost_Multiplier))
			character.Current_Mana -= round(this.Cost * this.Mana_Cost_Multiplier)
			If (character.Current_Mana < 0)
			{
				character.Current_HP += character.Current_Mana
				If (character.Current_HP < 0)
				{
					Msgbox % character.Name " died from mana-shock! Their mana dropped to " character.Current_Mana ", which reduced their HP to " character.Current_HP " out of " character.Maximum_HP " HP!"
					Dead.Push(character.Name)
				}
				Else
					Msgbox % character.Name " fainted from exhaustion due to that mana dropped to " character.Current_Mana "! HP was also reduced to " character.Current_HP " out of " character.Maximum_HP " HP."
			}
			If (target != "None")
				this.Spell_Damage(target)
		}
	}
		
	Spell_Damage(target)
	{
		target.Current_HP -= round(this.Power * this.Power_Multiple)
		If (target.Current_HP < 0)
		{	
			Msgbox % target.Name " has been destroyed! Their HP are at " target.Current_HP "/" target.Maximum_HP "!"
			Dead.Push(target.Name)
		}
		Else
			Msgbox % target.Name " lost " round(this.Power * this.Power_Multiple) " hitpoints! They are now at " target.Current_HP "/" target.Maximum_HP " HP!"
	}
}


; ### GUI ###
Gui, Wizwar: Color, black
Gui, Wizwar: Font, s14 bold, verdana
Gui, Wizwar: Add, Text, cwhite, Wizard Wars!
Gui, Wizwar: Font, s12 normal, verdana
Gui, Wizwar: Add, Text, cwhite, How many wizards will participate?
Loop % Names.MaxIndex()
	If (A_Index = 1)
		continue
	Else
		Count_DDL .= A_Index "|"
Gui, Wizwar: Add, DropDownList, vWizard_Count w50 center choose1, % Count_DDL
Gui, Wizwar: Add, Button, section xm default gFight, Fight!
Gui, Wizwar: Add, Button, ys gExit, Exit!
Gui, Wizwar: Show, Autosize, Wizard wars!
return

Exit:
WizwarGuiClose:
WizwarGuiEscape:
Exitapp


; ### GAME ROOSTER SETUP ###
Fight:
Gui, Wizwar: Submit
Loop % Wizard_Count ; <--- Creates wizards from the character class equal to the number specified in the Wizard_Count-variable
{
	Wizard%A_Index% := new Character(Names[Test := character.Rand(Names.MinIndex(), Names.MaxIndex())])
	Names.RemoveAt(Test)
	Wizard_Names .= Wizard%A_Index%.Name ","
}

Wizard_Names := StrSplit(Wizard_Names, ",") ; <--- Creates an array with the names of the chosen wizards
Wizard_Names.Pop()

Contest_String := "The duelling wizards are:`r`n"

Loop % Wizard_Names.MaxIndex()
	Contest_String .= A_Index ". " Wizard_Names[A_Index] " - Level: " Wizard%A_Index%.Level ", HP: " Wizard%A_Index%.Current_HP ", Mana: " Wizard%A_Index%.Current_Mana "/" Wizard%A_Index%.Maximum_Mana "`r`n"

Msgbox % Contest_String

Start: ; <--- This is where the game restarts if more than one wizard is alive at the end

Loop % Wizard_Count ; <--- Lets the wizards cast their spells in order, unless they are already dead
{
	wiz := character.Rand(1, Wizard_Count)
	If (Wizard%A_Index%.Current_HP < 0)
	{
		continue
	}
	Else
	{
		If (Wizard%A_Index% = Wizard%wiz%)
			Msgbox % Wizard%A_Index%.Name " fumbles the spell!"
		Else
			new Cast(Spells[character.Rand(Spells.MinIndex(), Spells.MaxIndex())], Wizard%A_Index%, Wizard%wiz%)
	}
}

Still_Alive := "Wizards still alive:`r`n"

Loop % Wizard_Names.MaxIndex() ; <--- Checks if wizards are still alive, and if so, writes them to a string variable and checks if more than one is still alive
{
	if (Wizard%A_Index%.Current_HP < 0)
	{
		Wizard_Names.RemoveAt(A_Index)
		continue
	}
	Else
	{
		Living++
		Still_Alive .= Wizard%A_Index%.Name " - HP: " Wizard%A_Index%.Current_HP "/" Wizard%A_Index%.Maximum_HP ", Mana: " Wizard%A_Index%.Current_Mana "/" Wizard%A_Index%.Maximum_Mana "`r`n"
	}
}

If (Living = 0)
	Msgbox % "Noone is still alive."
Else
	Msgbox % Still_Alive

If (Living <= 1)
	Exitapp
Else
{
	Wizard_Count := Living
	Living := 0
	Goto, Start ; <--- Restarts the game if more than one wizard is alive!
}