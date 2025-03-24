# Dev shell with python and common dependencies I use for data science and exploration
# shell hook installs jupyter kernel and starts jupyter server

{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  # install jupyter kernel and start server
  shellHook = ''
    jupyter kernel install --user --name=datascience
  '';
  # to auto-start jupyter server, move this line to shellHook
  # jupyter server --no-browser --ip=0.0.0.0 --port=8888 --NotebookApp.token=\'\' --NotebookApp.password=\'\'

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

        langchain
        langchain-core
        langchain-community

        openpyxl # pandas xlsx reader
        xlsx2csv # polars xlsx reader
        #fastexcel # polars excel compat
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
