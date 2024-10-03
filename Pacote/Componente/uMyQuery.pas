unit uMyQuery;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB, System.Generics.Collections,

  uSistema;

type
  TMyQuery = class(TADOQuery)
  private
    FListaBeforePost: TList<TProc<TDataSet>>;
    FListaAfterOpen: TList<TProc<TDataSet>>;
    FListaAfterInsert: TList<TProc<TDataSet>>;

    procedure OnBeforePost(prValor: TDataSet);
    procedure OnAfterOpen(prValor: TDataSet);
    procedure OnAfterInsert(prValor: TDataSet);
  protected
    procedure DoBeforeOpen; override;
  public
     procedure AddBeforePost(prProc: TDataSetNotifyEvent);
     procedure AddAfterOpen(prProc: TDataSetNotifyEvent);
     procedure AddAfterInsert(prProc: TDataSetNotifyEvent);

     constructor Create(AOwner: TComponent); override;
     destructor Destroy; override;
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('My Components', [TMyQuery]);
end;

{ TMyQuery }

destructor TMyQuery.Destroy;
begin
  if Assigned(FListaBeforePost) then
    FListaBeforePost.Free();

  if Assigned(FListaAfterOpen) then
    FListaAfterOpen.Free();

  if Assigned(FListaAfterInsert) then
    FListaAfterInsert.Free();

  inherited;
end;

procedure TMyQuery.DoBeforeOpen;
begin
  inherited;

  //
end;

procedure TMyQuery.OnAfterInsert(prValor: TDataSet);
var
  vIndex: Integer;
begin
  if Assigned(FListaAfterInsert) then
  begin
    for vIndex := 0 to FListaAfterInsert.Count - 1 do
      FListaAfterInsert.Items[vIndex](prValor);
  end;
end;

procedure TMyQuery.OnAfterOpen(prValor: TDataSet);
var
  vIndex: Integer;
begin
  if Assigned(FListaAfterOpen) then
  begin
    for vIndex := 0 to FListaAfterOpen.Count - 1 do
      FListaAfterOpen.Items[vIndex](prValor);
  end;
end;

procedure TMyQuery.OnBeforePost(prValor: TDataSet);
var
  vIndex: Integer;
begin
  if Assigned(FListaBeforePost) then
  begin
    for vIndex := 0 to FListaBeforePost.Count - 1 do
      FListaBeforePost.Items[vIndex](prValor);
  end;
end;

procedure TMyQuery.AddAfterInsert(prProc: TDataSetNotifyEvent);
begin
  if not Assigned(FListaAfterInsert) then
    FListaAfterInsert := TList<TProc<TDataSet>>.Create;

  FListaAfterInsert.Add(prProc);
end;

procedure TMyQuery.AddAfterOpen(prProc: TDataSetNotifyEvent);
begin
  if not Assigned(FListaAfterOpen) then
    FListaAfterOpen := TList<TProc<TDataSet>>.Create;

  FListaAfterOpen.Add(prProc);
end;

procedure TMyQuery.AddBeforePost(prProc: TDataSetNotifyEvent);
begin
  if not Assigned(FListaBeforePost) then
    FListaBeforePost := TList<TProc<TDataSet>>.Create;

  FListaBeforePost.Add(prProc);
end;

constructor TMyQuery.Create(AOwner: TComponent);
begin
  inherited;

  Self.BeforePost := Self.OnBeforePost;
  Self.AfterOpen := Self.OnAfterOpen;
  Self.AfterInsert := Self.OnAfterInsert;

  if Self.Connection = nil then
    Self.Connection := Sistema.GetConexao();
end;

end.
