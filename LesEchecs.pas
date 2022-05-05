unit LesEchecs;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.UITypes, System.Variants, System.Classes, Vcl.Graphics, System.Generics.Collections,
	Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage, Vcl.StdCtrls, System.Math;

{$REGION 'Types'}
type
	TCouleurPiece = (blanc, noir);

	// On declare TCase et TPiece directement car ils s'appellent reciproquement
	TCase = class;
	TPiece = class;

	// Case de l'Fechiquier
	TCase = class(TShape)
	private
		Foccupant : TPiece; // Piece occupant la case
		FpositionX : Integer;
		FpositionY : Integer;
	public
		procedure Colorer(r, g, b: Integer); 
		procedure ChangerEtat(etat : string);
	end;

	// Type abstrait modelisant une piece puis types specifiques pour chacune
	TPiece = class(TImage)
	private
		Fcouleur : TCouleurPiece;
		Fposition : TCase;
	public
		constructor Create(case_ : TCase; couleur : TCouleurPiece); reintroduce; virtual;

		procedure Deplacer(case_ : TCase);
		procedure CanMove; virtual; abstract;
		procedure PieceMourir;
		procedure DeplacementEnLigne;
		procedure DeplacementDiagonal;

		procedure PieceClick(Sender: TObject);
	end;
	
	TPiecePion = class(TPiece)
	public
		constructor Create(case_ : TCase; couleur : TCouleurPiece); override;
		procedure CanMove; override;
		procedure PromotionPion(couleur : TCouleurPiece);
	end;

	TPieceTour = class(TPiece)
	public
		constructor Create(case_ : TCase; couleur : TCouleurPiece); override;
		procedure CanMove; override;
	end;

	TPieceCavalier = class(TPiece)
	public
		constructor Create(case_ : TCase; couleur : TCouleurPiece); override;
		procedure CanMove; override;
	end;

	TPieceFou = class(TPiece)
	public
		constructor Create(case_ : TCase; couleur : TCouleurPiece); override;
		procedure CanMove; override;
	end;

	TPieceDame = class(TPiece)
	public
		constructor Create(case_ : TCase; couleur : TCouleurPiece); override;
		procedure CanMove; override;
	end;

	TPieceRoi = class(TPiece)
	public
		constructor Create(case_ : TCase; couleur : TCouleurPiece); override;
		procedure CanMove; override;
	end;

	TFenetre = class(TForm)
	public
		Fechiquier: array[0..7, 0..7] of TCase; // rangement des cases
		{listes de pieces non utilisees, mobilisees pour le systeme de mise en echec pas encore geree}
		FpiecesBlanches: TObjectList<TPiece>;
		FpiecesNoires: TObjectList<TPiece>;
		FpieceSelection: TPiece;
		Ftourdejeu: TCouleurPiece;
		procedure InitialiserPartie;
		procedure ResetSelection;
		procedure JoueurChange;
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

// permet d'obtenir l'evenement onclick pour les cases

procedure TSetClick.SetOnClick(clickEvent: TNotifyEvent);
begin
	self.OnClick := clickEvent;
end;

procedure TSetClick.SetOnDblClick(clickEvent: TNotifyEvent);
begin
	self.OnDblClick := clickEvent;
end;

{$ENDREGION}

// creation du plateau
procedure TFenetre.Initialisation(Sender: TObject);
var
	colonne, ligne : integer;
	tmp : TCase;
begin
	self.Color := RGB(22, 21, 19);
	self.FpieceSelection := Nil;

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

		if (colonne + ligne) mod 2 = 0 then
			tmp.Colorer(181, 136, 99)
		else
			tmp.Colorer(240, 217, 181);

		tmp.FpositionX := colonne;
		tmp.FpositionY := ligne;
		tmp.Foccupant := nil;
		self.Fechiquier[colonne, ligne] := tmp;
	end;

	self.FpiecesBlanches := TObjectList<TPiece>.Create;
	self.FpiecesNoires := TObjectList<TPiece>.Create;
	self.Ftourdejeu := blanc;
	self.InitialiserPartie;
end;

// creation et placement des pieces
procedure TFenetre.InitialiserPartie;
var
	i : integer;
begin
	for i := 0 to 7 do
	begin
		TPiecePion.Create(self.Fechiquier[i,1], TCouleurPiece.blanc);
		TPiecePion.Create(self.Fechiquier[i,6], TCouleurPiece.noir);
	end;
	TPieceTour.Create(self.Fechiquier[0,0], TCouleurPiece.blanc);
	TPieceCavalier.Create(self.Fechiquier[1,0], TCouleurPiece.blanc);
	TPieceFou.Create(self.Fechiquier[2,0], TCouleurPiece.blanc);
	TPieceDame.Create(self.Fechiquier[3,0], TCouleurPiece.blanc);
	TPieceRoi.Create(self.Fechiquier[4,0], TCouleurPiece.blanc);
	TPieceFou.Create(self.Fechiquier[5,0], TCouleurPiece.blanc);
	TPieceCavalier.Create(self.Fechiquier[6,0], TCouleurPiece.blanc);
	TPieceTour.Create(self.Fechiquier[7,0], TCouleurPiece.blanc);
	TPieceTour.Create(self.Fechiquier[0,7], TCouleurPiece.noir);
	TPieceCavalier.Create(self.Fechiquier[1,7], TCouleurPiece.noir);
	TPieceFou.Create(self.Fechiquier[2,7], TCouleurPiece.noir);
	TPieceDame.Create(self.Fechiquier[3,7], TCouleurPiece.noir);
	TPieceRoi.Create(self.Fechiquier[4,7], TCouleurPiece.noir);
	TPieceFou.Create(self.Fechiquier[5,7], TCouleurPiece.noir);
	TPieceCavalier.Create(self.Fechiquier[6,7], TCouleurPiece.noir);
	TPieceTour.Create(self.Fechiquier[7,7], TCouleurPiece.noir);
end;

// Colore la case en entier de la meme couleur : son coeur et sa bordure
procedure TCase.Colorer(r, g, b: Integer);
var
	couleur: TColor;
begin
	couleur := RGB(r, g, b);
	self.Pen.Color := couleur;
	self.Brush.Color := couleur;
end;

// Colore les cases selon leur état
procedure TCase.ChangerEtat(etat : string);
begin
	if etat = 'deplacement' then
		self.Colorer(176,242,182)
	else if etat = 'attaque' then
		self.Colorer(187,11,11)
	else
end;

{ Après un coup joué ou à l'annulation de la sélection d'une pièce (clic sur une case ni rogue ni vert),
reset la couleur des cases et place FpieceSelection sur false }
procedure TFenetre.ResetSelection;
var
	i, j : integer;
begin
	for i := 0 to 7 do
	for j := 0 to 7 do
	begin
		if (i + j) mod 2 = 0 then
			self.Fechiquier[i,j].Colorer(181, 136, 99)
		else
			self.Fechiquier[i,j].Colorer(240, 217, 181);
	end;		
	self.FpieceSelection := Nil;
end;

procedure TFenetre.JoueurChange;
begin
	if self.Ftourdejeu = TCouleurPiece.blanc then
		self.Ftourdejeu := TCouleurPiece.noir
	else
		self.Ftourdejeu := TCouleurPiece.blanc;
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

	self.OnClick := PieceClick;

	case_.Foccupant := self;

	if couleur = blanc then
		Fenetre.FpiecesBlanches.Add(self)
	else
		Fenetre.FpiecesNoires.Add(self);
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

{$REGION 'Deplacement de pieces'}

procedure TPiecePion.CanMove;
var
	x,y : integer;
begin
	x := Self.FPosition.FpositionX;
	y := Self.FPosition.FpositionY;

	// deplacements et prises possibles et de prise du pion blanc
	if self.Fcouleur = TCouleurPiece.blanc then
	begin	
		if (y < 7) then
			// deplacement simple
			if (Fenetre.Fechiquier[x, y + 1].Foccupant = Nil) then
				begin
					Fenetre.Fechiquier[x, y + 1].Brush.Color := clGreen;
					// deplacement double
					if (Fenetre.Fechiquier[x, y + 2].Foccupant = Nil) and (y = 1) then
						Fenetre.Fechiquier[x, y + 2].Brush.Color := clGreen;
				end;
		// prise possible sur la diagonale gauche
		if (x > 0) and (y < 7) then
			if (Fenetre.Fechiquier[x - 1, y + 1].Foccupant <> Nil)
				and (Fenetre.Fechiquier[x - 1, y + 1].Foccupant.Fcouleur = TCouleurPiece.noir) then
				Fenetre.Fechiquier[x - 1, y + 1].Brush.Color := clRed;
		// prise possible sur la diagonale droite
		if (x < 7) and (y < 7) then
			if (Fenetre.Fechiquier[x + 1, y + 1].Foccupant <> Nil)
				and (Fenetre.Fechiquier[x + 1, y + 1].Foccupant.Fcouleur = TCouleurPiece.noir) then
				Fenetre.Fechiquier[x + 1, y + 1].Brush.Color := clRed;
	end;
	// déplacements et prises possibles et de prise du pion blanc
	if self.Fcouleur = TCouleurPiece.noir then
	begin	
		if (y > 0) then
			if (Fenetre.Fechiquier[x, y - 1].Foccupant = Nil) then
			begin
				Fenetre.Fechiquier[x, y - 1].Brush.Color := clGreen;
				if (Fenetre.Fechiquier[x, y - 2].Foccupant = Nil) and (y = 6) then
					Fenetre.Fechiquier[x, y - 2].Brush.Color := clGreen
			end;
		if (x > 0) and (y > 0) then
			if (Fenetre.Fechiquier[x - 1, y - 1].Foccupant <> Nil)
				and (Fenetre.Fechiquier[x - 1, y - 1].Foccupant.Fcouleur = TCouleurPiece.blanc) then
				Fenetre.Fechiquier[x - 1, y - 1].Brush.Color := clRed;
		if (x < 7) and (y > 0) then
			if (Fenetre.Fechiquier[x + 1, y - 1].Foccupant <> Nil)
				and (Fenetre.Fechiquier[x + 1, y - 1].Foccupant.Fcouleur = TCouleurPiece.blanc) then
				Fenetre.Fechiquier[x + 1, y - 1].Brush.Color := clRed;
	end;
end;

procedure TPiecePion.PromotionPion(couleur : TCouleurPiece);
var
	tmp : TCase;
begin
	tmp := Fenetre.FpieceSelection.Fposition;
	Fenetre.FpieceSelection.Destroy; // destruction du pion
	if couleur = TCouleurPiece.blanc then
		TPieceDame.Create(tmp, TCouleurPiece.blanc) //  création de la dame blanche // bon appétit !
	else
		TPieceDame.Create(tmp, TCouleurPiece.noir); // création de la dame noire // bon appétit !
end;

procedure TPieceTour.CanMove;
begin
	self.DeplacementEnLigne;
end;

procedure TPieceCavalier.CanMove;
var
	i, j, xself, yself, xother, yother  : integer;
begin
	xself := self.Fposition.FpositionX;
	yself := self.Fposition.FpositionY;

	// definit de maniere securisee les 8 mouvements du cavalier

	for i := 0 to 7 do
	for j := 0 to 7 do
	begin
		xother := Fenetre.Fechiquier[i, j].FpositionX;
		yother := Fenetre.Fechiquier[i, j].FpositionY;
		if ((xother - xself) * (xother - xself) + (yother - yself) * (yother - yself)) = 5 then
			if Fenetre.Fechiquier[i, j].Foccupant = Nil then
				Fenetre.Fechiquier[i, j].Brush.Color := clGreen
			else if Fenetre.Fechiquier[i, j].Foccupant.Fcouleur <> self.Fcouleur then
				Fenetre.Fechiquier[i, j].Brush.Color := clRed;
	end;
end;

procedure TPieceFou.CanMove;
begin
	self.DeplacementDiagonal;
end;

procedure TPieceDame.CanMove;
begin
	self.DeplacementEnLigne;
	self.DeplacementDiagonal;
end;

procedure TPieceRoi.CanMove;
var
	i, j, x, y : integer;
begin
	x := self.Fposition.FpositionX;
	y := self.Fposition.FpositionY;
	// double boucle pour tester toutes les cases adjacentes du roi
	for i := -1 to 1 do
		for j := -1 to 1 do
			// conditions pour etre sûr de ne pas sortir de l'Fechiquier
			if (x + i >= 0) and (x + i <= 7) and (y + j >= 0) and (y + j <= 7) then
			begin
				// si case libre et accessible, colorier la case en vert
				if Fenetre.Fechiquier[x + i, y + j].Foccupant = Nil then
					Fenetre.Fechiquier[x + i, y + j].Brush.Color := clGreen 
				// si case occupe par l'adversaire, colorier la case en rouge
				else if Fenetre.Fechiquier[x + i, y + j].Foccupant.Fcouleur <> self.Fcouleur then
					Fenetre.Fechiquier[x + i, y + j].Brush.Color := clRed
			end;
end;

procedure TPiece.DeplacementEnLigne;
var
	i, x, y : integer;
	testSortie : Boolean;
begin
	x := self.Fposition.FpositionX;
	y := self.Fposition.FpositionY;

	// mouvements possibles vers le haut
	i := y;
	testSortie := true;
	while (i < 7) and testSortie do
	begin
		i := i + 1;
		if (Fenetre.Fechiquier[x, i].Foccupant) = nil then
			Fenetre.Fechiquier[x, i].Brush.Color := clGreen
		else
		begin
			if (Fenetre.Fechiquier[x, i].Foccupant.Fcouleur) <> (self.Fcouleur) then
				Fenetre.Fechiquier[x, i].Brush.Color := clRed;
			testSortie := false;
		end;
	end;
	// mouvements possibles vers le bas
	i := y;
	testSortie := true;
	while (i > 0) and testSortie do
	begin
		i := i - 1;
		if Fenetre.Fechiquier[x, i].Foccupant = Nil then
			Fenetre.Fechiquier[x, i].Brush.Color := clGreen
		else
		begin
			if (Fenetre.Fechiquier[x, i].Foccupant.Fcouleur) <> (self.Fcouleur) then
				Fenetre.Fechiquier[x, i].Brush.Color := clRed;
			testSortie := false;
		end;
	end;
	// mouvements possibles vers la droite
	i := x;
	testSortie := true;
	while (i < 7) and testSortie do
	begin
		i := i + 1;
		if Fenetre.Fechiquier[i, y].Foccupant = Nil then
			Fenetre.Fechiquier[i, y].Brush.Color := clGreen
		else
		begin
			if (Fenetre.Fechiquier[i, y].Foccupant.Fcouleur) <> (self.Fcouleur) then
				Fenetre.Fechiquier[i, y].Brush.Color := clRed;
			testSortie := false;
		end;
	end;
	// mouvements possibles vers la gauche
	i := x;
	testSortie := true;
	while (i > 0) and (testSortie = True) do
	begin
		i := i - 1;
		if (Fenetre.Fechiquier[i, y].Foccupant = Nil) then
			Fenetre.Fechiquier[i, y].Brush.Color := clGreen
		else
		begin
			if (Fenetre.Fechiquier[i, y].Foccupant.Fcouleur) <> (self.Fcouleur) then
				Fenetre.Fechiquier[i, y].Brush.Color := clRed;
			testSortie := false;
		end;
	end;
end;

procedure TPiece.DeplacementDiagonal;
var
	i, x, y : integer;
	testSortie : Boolean;
begin
	x := self.Fposition.FpositionX;
	y := self.Fposition.FpositionY;

	// mouvements possibles en diagonal direction haut-droit
	i := 1;
	testSortie := true;
	while (x + i <= 7) and (y + i <= 7) and testSortie do
	begin
		if (Fenetre.Fechiquier[x + i, y + i].Foccupant) = nil then
			Fenetre.Fechiquier[x + i, y + i].Brush.Color := clGreen
		else
		begin
			if (Fenetre.Fechiquier[x + i, y + i].Foccupant.Fcouleur) <> (self.Fcouleur) then
				Fenetre.Fechiquier[x + i, y + i].Brush.Color := clRed;
			testSortie := false;
		end;
		i := i + 1;
	end;
	// mouvements possibles en diagonal direction haut-gauche
	i := 1;
	testSortie := true;
	while (x - i >= 0) and (y + i <= 7) and testSortie do
	begin
		if (Fenetre.Fechiquier[x - i, y + i].Foccupant) = nil then
			Fenetre.Fechiquier[x - i, y + i].Brush.Color := clGreen
		else
		begin
			if (Fenetre.Fechiquier[x - i, y + i].Foccupant.Fcouleur) <> (self.Fcouleur) then
				Fenetre.Fechiquier[x - i, y + i].Brush.Color := clRed;
			testSortie := false;
		end;
		i := i + 1;
	end;
	// mouvements possibles en diagonale direction bas-droite
	i := 1;
	testSortie := true;
	while (x + i <= 7) and (y - i >= 0) and testSortie do
	begin
		if (Fenetre.Fechiquier[x + i, y - i].Foccupant) = nil then
			Fenetre.Fechiquier[x + i, y - i].Brush.Color := clGreen
		else
		begin
			if (Fenetre.Fechiquier[x + i, y - i].Foccupant.Fcouleur) <> (self.Fcouleur) then
				Fenetre.Fechiquier[x + i, y - i].Brush.Color := clRed;
			testSortie := false;
		end;
		i := i + 1;
	end;
	// mouvements possibles en diagonale direction bas-gauche
	i := 1;
	testSortie := true;
	while (x - i >= 0) and (y - i >= 0) and testSortie do
	begin
		if (Fenetre.Fechiquier[x - i, y - i].Foccupant) = nil then
			Fenetre.Fechiquier[x - i, y - i].Brush.Color := clGreen
		else
		begin
			if (Fenetre.Fechiquier[x - i, y - i].Foccupant.Fcouleur) <> (self.Fcouleur) then
				Fenetre.Fechiquier[x - i, y - i].Brush.Color := clRed;
			testSortie := false;
		end;
		i := i + 1;
	end;
end;

procedure TPiece.Deplacer(case_ : TCase);
begin
	// 1) changer le FOccupant du TCase sur Nil
	Fenetre.FpieceSelection.Fposition.Foccupant := Nil;
	// 2) mettre le FOccupant de la nouvelle TCase avec la nouvelle piece
	case_.Foccupant := Fenetre.FpieceSelection;
	// 3) modifier le Fposition du TPiece avec la nouvelle case
	Fenetre.FpieceSelection.Fposition := Fenetre.Fechiquier[case_.FpositionX, case_.FpositionY];
	// 4) déplacer l'image, effectue la promotion du pion si nécessaire (changement de la piece)
	if (Fenetre.FpieceSelection.Fposition.FpositionY = 7) and (Fenetre.FpieceSelection.ClassType = TPiecePion)
		and (Fenetre.FpieceSelection.Fcouleur = TCouleurPiece.blanc) then
		(self as TPiecePion).PromotionPion(blanc)
	else if (Fenetre.FpieceSelection.Fposition.FpositionY = 0) and (Fenetre.FpieceSelection.ClassType = TPiecePion)
		and (Fenetre.FpieceSelection.Fcouleur = TCouleurPiece.noir) then
		(self as TPiecePion).PromotionPion(noir)
	else
	begin
		Fenetre.FpieceSelection.Top := case_.Top;
		Fenetre.FpieceSelection.Left := case_.Left;
	end;
	// 5) reset les couleurs de plateau et la selection de la piece
	Fenetre.ResetSelection;
	Fenetre.Joueurchange;
end;

{$ENDREGION}

procedure TPiece.PieceMourir;
var
	tmp : TCase;
begin
	tmp := Self.Fposition;
	Self.Destroy; // tue la piece
	Fenetre.FpieceSelection.Deplacer(tmp); // le vainqueur prend la place du pion dechu
end;

procedure TFenetre.CaseClick (Sender : TObject);
var
	case_: TCase;
begin
	case_ := Sender as TCase;
	// renvoie vers la fonction de deplacement si la case recevant le clic est verte
	if case_.Brush.Color = clGreen then
		self.FpieceSelection.Deplacer(case_)
	else
		// aucun effet sinon, on deselectionne
		self.ResetSelection;
end;

procedure TPiece.PieceClick(Sender: TObject);
var
	piece: TPiece;
begin
	piece := Sender as TPiece;
	
	{ si aucune piece selectionnee, et si le sender est de la couleur du joueur
		dont c'est le tour, on passe a la selection et a la coloration }
	if (Fenetre.FpieceSelection = Nil) and (piece.Fcouleur = Fenetre.Ftourdejeu) then
	begin
		Fenetre.FpieceSelection := piece; // enregistre la piece selectionnee
		piece.CanMove;
	end
	// si une piece est selectionnee, le clic sur une piece sur case rouge lance une attaque, sinon on deselectionne
	else if piece.Fposition.Brush.Color = clRed then
		piece.PieceMourir
	else
		Fenetre.ResetSelection;
end;	

end.