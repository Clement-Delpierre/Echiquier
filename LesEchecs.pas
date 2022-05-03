unit LesEchecs;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.Generics.Collections,
	Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage;

{$REGION 'Types'}
type
	TCouleurPiece = (blanc, noir);

	// On declare TCase et TPiece directement car ils s'appellent reciproquement
	TCase = class;
	TPiece = class;

	// Type modelisant une case de l'echiquier
	TCase = class(TShape)
	private
		Foccupant : TPiece;
		FpositionX : Integer;
		FpositionY : Integer;
	public
		procedure Colorer(r, g, b: Integer);
	end;

	// Type abstrait modelisant une piece puis types specifiques pour chacune
	TPiece = class(TImage)
	private
		Fcouleur : TCouleurPiece;
		Fposition : TCase;
	public
		constructor Create(case_ : TCase; couleur : TCouleurPiece); reintroduce; virtual;

		procedure TuerPiece(piece : TPiece);
		procedure Deplacer; virtual; abstract;

		procedure PieceClick(sender: TObject);
	end;
	
	TPiecePion = class(TPiece)
	public
		constructor Create(case_ : TCase; couleur : TCouleurPiece); override;
		procedure Deplacer; override;
	end;

	TPieceTour = class(TPiece)
	public
		constructor Create(case_ : TCase; couleur : TCouleurPiece); override;
		procedure Deplacer; override;
	end;

	TPieceCavalier = class(TPiece)
	public
		constructor Create(case_ : TCase; couleur : TCouleurPiece); override;
		procedure Deplacer; override;
	end;

	TPieceFou = class(TPiece)
	public
		constructor Create(case_ : TCase; couleur : TCouleurPiece); override;
		procedure Deplacer; override;
	end;

	TPieceDame = class(TPiece)
	public
		constructor Create(case_ : TCase; couleur : TCouleurPiece); override;
		procedure Deplacer; override;
	end;

	TPieceRoi = class(TPiece)
	public
		constructor Create(case_ : TCase; couleur : TCouleurPiece); override;
		procedure Deplacer; override;
	end;

	TFenetre = class(TForm)
	public
		echiquier: array[0..7, 0..7] of TCase;
		piecesBlanches: TObjectList<TPiece>;
		piecesNoires: TObjectList<TPiece>;
		procedure InitialiserPartie;
	published
		procedure Initialisation(Sender: TObject);
		procedure CaseClick(Sender : TObject);
	end;

	TSetClick = class helper for TControl
		procedure SetOnClick(clickEvent: TNotifyEvent); inline;
		procedure SetOnDblClick(clickEvent: TNotifyEvent); inline;
	end;

{$ENDREGION}

var
	Fenetre: TFenetre;

implementation

{$R *.dfm}

{$REGION 'Gestion des clics'}

procedure TSetClick.SetOnClick(clickEvent: TNotifyEvent);
begin
	self.OnClick := clickEvent;
end;

procedure TSetClick.SetOnDblClick(clickEvent: TNotifyEvent);
begin
	self.OnDblClick := clickEvent;
end;

procedure TFenetre.CaseClick (Sender : TObject);
var
	case_: TCase;
begin
	case_ := Sender as TCase;

	ShowMessage('Vous avez click sur la case : ' + IntToStr(case_.FpositionX) + IntToStr(case_.FpositionY) 
  		+ '.');
end;

procedure TPiece.PieceClick(Sender: TObject);
var
	piece: TPiece;
begin
	piece := Sender as TPiece;

	if Sender.ClassNameIs('TPiecePion') and (piece.Fcouleur = TCouleurPiece.blanc) then
		self.Deplacer;
end;

{$ENDREGION}

procedure TCase.Colorer(r, g, b: Integer);
var
	couleur: TColor;
begin
	couleur := RGB(r, g, b);
	self.Pen.Color := couleur;
	self.Brush.Color := couleur;
end;

procedure TFenetre.Initialisation(Sender: TObject);
var
	colonne, ligne : integer;
	tmp : TCase;
begin
	self.Color := RGB(22, 21, 19);

	for colonne := 0 to 7 do
	for ligne := 0 to 7 do
	begin
		tmp := TCase.Create(self);
		tmp.Parent := self;

		tmp.Height := 64;
		tmp.Width := 64;

		tmp.Left := 32 + colonne * 64;
		tmp.Top := 32 + (7 - ligne) * 64;

		tmp.SetOnClick(CaseClick);

		tmp.Pen.Width := 32;
		if (colonne + ligne) mod 2 = 0 then
			tmp.Colorer(181, 136, 99)
		else
			tmp.Colorer(240, 217, 181);

		tmp.FpositionX := colonne;
		tmp.FpositionY := ligne;
		self.echiquier[colonne, ligne] := tmp;
	end;

	self.piecesBlanches := TObjectList<TPiece>.Create;
	self.piecesNoires := TObjectList<TPiece>.Create;
	self.InitialiserPartie;
end;

procedure TFenetre.InitialiserPartie;
var
	i : integer;
begin
	for i := 0 to 7 do
	begin
		TPiecePion.Create(self.echiquier[i,1], TCouleurPiece.blanc);
		TPiecePion.Create(self.echiquier[i,6], TCouleurPiece.noir);
	end;
	TPieceTour.Create(self.echiquier[0,0], TCouleurPiece.blanc);
	TPieceCavalier.Create(self.echiquier[1,0], TCouleurPiece.blanc);
	TPieceFou.Create(self.echiquier[2,0], TCouleurPiece.blanc);
	TPieceDame.Create(self.echiquier[3,0], TCouleurPiece.blanc);
	TPieceRoi.Create(self.echiquier[4,0], TCouleurPiece.blanc);
	TPieceFou.Create(self.echiquier[5,0], TCouleurPiece.blanc);
	TPieceCavalier.Create(self.echiquier[6,0], TCouleurPiece.blanc);
	TPieceTour.Create(self.echiquier[7,0], TCouleurPiece.blanc);
	TPieceTour.Create(self.echiquier[0,7], TCouleurPiece.noir);
	TPieceCavalier.Create(self.echiquier[1,7], TCouleurPiece.noir);
	TPieceFou.Create(self.echiquier[2,7], TCouleurPiece.noir);
	TPieceDame.Create(self.echiquier[3,7], TCouleurPiece.noir);
	TPieceRoi.Create(self.echiquier[4,7], TCouleurPiece.noir);
	TPieceFou.Create(self.echiquier[5,7], TCouleurPiece.noir);
	TPieceCavalier.Create(self.echiquier[6,7], TCouleurPiece.noir);
	TPieceTour.Create(self.echiquier[7,7], TCouleurPiece.noir);
end;

{$REGION 'Constructeurs de pieces'}

constructor TPiece.Create(case_ : TCase; couleur : TCouleurPiece);
begin
	inherited Create(Fenetre);
	self.Fcouleur := couleur;
	self.Fposition := case_;
	self.Height := 64;
	self.Width := 64;
	self.Top := case_.Top;
	self.Left := case_.Left;
	self.Stretch := true;
	self.Parent := case_.Parent;

	// self.OnDblClick := ImageDblClick;
	self.OnClick := PieceClick;

	case_.Foccupant := self;

	if couleur = blanc then
		Fenetre.piecesBlanches.Add(self)
	else
		Fenetre.piecesNoires.Add(self);
end;

constructor TPieceRoi.Create(case_ : TCase; couleur : TCouleurPiece);
begin
	inherited Create(case_, couleur);

	if couleur = blanc then
		self.Picture.LoadFromFile('../../Images/kingW.png')
	else
		self.Picture.LoadFromFile('../../Images/kingB.png');
end;

constructor TPieceDame.Create(case_ : TCase; couleur : TCouleurPiece);
begin
	inherited Create(case_, couleur);

	if couleur = blanc then
		self.Picture.LoadFromFile('../../Images/QueenW.png')
	else
		self.Picture.LoadFromFile('../../Images/QueenB.png');
end;

constructor TPieceFou.Create(case_ : TCase; couleur : TCouleurPiece);
begin
	inherited Create(case_, couleur);

	if couleur = blanc then
		self.Picture.LoadFromFile('../../Images/bishopW.png')
	else
		self.Picture.LoadFromFile('../../Images/bishopB.png');
end;

constructor TPieceCavalier.Create(case_ : TCase; couleur : TCouleurPiece);
begin
	inherited Create(case_, couleur);

	if couleur = blanc then
		self.Picture.LoadFromFile('../../Images/knightW.png')
	else
		self.Picture.LoadFromFile('../../Images/knightB.png');
end;

constructor TPieceTour.Create(case_ : TCase; couleur : TCouleurPiece);
begin
	inherited Create(case_, couleur);

	if couleur = blanc then
		self.Picture.LoadFromFile('../../Images/rookW.png')
	else
		self.Picture.LoadFromFile('../../Images/rookB.png');
end;

constructor TPiecePion.Create(case_ : TCase; couleur : TCouleurPiece);
begin
	inherited Create(case_, couleur);

	if couleur = blanc then
		self.Picture.LoadFromFile('../../Images/pawnW.png')
	else
		self.Picture.LoadFromFile('../../Images/pawnB.png');
end;

{$ENDREGION}

procedure TPiece.TuerPiece(piece: TPiece);
var
	tmp : TCase;
begin
	tmp := self.Fposition;
	self.Destroy;
	tmp.Foccupant := nil;	
end;

{$REGION 'Deplacement de pieces'}

procedure TPiecePion.Deplacer;
begin
	if Fenetre.echiquier[Self.FPosition.FpositionX, Self.FPosition.FpositionY + 1].Foccupant <> nil then
		ShowMessage('occupay!')
	else
	begin
		ShowMessage('DISPO');
		// TODO: self.Fposition.FpositionY :=
	end;
end;

procedure TPieceTour.Deplacer;
begin

end;

procedure TPieceCavalier.Deplacer;
begin

end;

procedure TPieceFou.Deplacer;
begin

end;

procedure TPieceDame.Deplacer;
begin

end;

procedure TPieceRoi.Deplacer;
begin

end;

{$ENDREGION}

end.