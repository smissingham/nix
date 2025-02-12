# Dev shell with python and common dependencies I use for data science and exploration

{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  shellHook = ''
    zsh
  '';

  nativeBuildInputs = with pkgs; [

    # --- Python --- #
    (python311.withPackages (
      ps: with ps; [
        numpy # these two are
        scipy # probably redundant to pandas
        pandas
        polars
        duckdb
        statsmodels
        scikitlearn

        openpyxl # pandas xlsx reader
        xlsx2csv # polars xlsx reader
        fastexcel # polars excel compat
        pyarrow # polars pivot

        pip
        jupyter
        jupyterlab
        ipykernel
        nbconvert
        nbformat

        # visualization
        plotly
        matplotlib
        seaborn
      ]
    ))

  ];
}
