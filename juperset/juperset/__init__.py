import sqlite3

import pandas as pd
from sqlalchemy import create_engine

class Juperset:
    """Class responsible for connecting to database and updating tables with data 
    from a DataFrame.
    """

    def __init__(self, conn_str: str):
        """Initialize the connection to the database.
        
        Parameters
        ----------
        conn_str : str
            A sqlalchemy connection string.
        """
        self.conn_str = conn_str
        # Create connection to database.
        self.engine = create_engine(conn_str, echo=False)

    
    def commit_dataframe(self, df: pd.DataFrame, table_name: str):
        """Commit `df` to database as a table named `table_name`, replacing if exists.
        
        Indices on Dataframes are ignored.

        Will eventually also create/update table info in superset configuration database.
        """
        df.to_sql(name=table_name, con=self.engine, if_exists='replace', index=False)

    

        