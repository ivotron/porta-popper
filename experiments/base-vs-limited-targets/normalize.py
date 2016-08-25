import pandas as pd


def obtain_speedup(df, base_machine):
   """Obtains a 'speedup' column w.r.t. a given base machine"""
    # get a dataframe with base results; only columns 'benchmark' and 'result'
    predicate = (df['machine'] == base_machine) & (df['limits'] == 'no_limits')
    base_results = df[predicate][['benchmark', 'result']]

    # rename the 'result' column
    base_results.rename(columns={'result': 'base_result'}, inplace=True)

    # merge all tests with the base_results column (join on 'benchmark' column)
    df = pd.merge(base_results, df)

    # and exclude the base system itself
    df = df[df['machine'] != base_machine]

    # lastly, get normalized results for target system w.r.t. the base system
    def get_speedup(row):
        if row['lower_is_better'] is True:
            speedup = row['base_result'] / row['result']
        else:
            speedup = row['result'] / row['base_result']

        if speedup < 1.0:
            speedup = 1 / speedup

        return speedup

    df['speedup'] = df.apply(get_speedup, axis=1)

    return df
