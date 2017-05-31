def listdir(dirname, pattern="*"):
    ''''''
    return fnmatch.filter(os.listdir(dirname), pattern)