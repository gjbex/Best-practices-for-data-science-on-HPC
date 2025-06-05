'''
Python module to read an indexed text file.  The text file is a concatenation of
text files, and is accompanied by an index file that specifies the number of
characters in each text file.  The index file is a text file with two columns:
    - the first column is the name of the text file, and
    - the second column is the number of characters in the text file.
The name of the index file is the name of the text file with the extension '.idx'.

The module provides a class, TextIndex, that reads the index file and allows the
user to read the text file by specifying the name of the text file, or by the
sequential index in the concatenated text file.  Additionally, the user can
specify the number of characters to read from the text file. The class provides
a method to return the number of text files in the concatenated text file.
'''

from collections import namedtuple
from functools import lru_cache


FileIndex = namedtuple('FileIndex', ['offset', 'nr_bytes'])


class TextIndex:
    '''
    Class to read an indexed text file.  The text file is a concatenation of text
    files, and is accompanied by an index file that specifies the number of
    characters in each text file.  The index file is a text file with two columns:
        - the first column is the name of the text file, and
        - the second column is the number of characters in the text file.
    '''

    def __init__(self, text_file_name, idx_file_name=None, max_cache_size=128):
        '''Initialize the TextIndex object by reading the index file.
        '''
        self._text_file_name = text_file_name
        self._text_file = open(text_file_name, 'rb')
        if idx_file_name is None:
            self._idx_file_name = text_file_name + '.idx'
        else:
            self._idx_file_name = idx_file_name
        self._index = self._read_index()
        self.read_text = lru_cache(maxsize=max_cache_size)(self._read_text)

    def __len__(self):
        '''Return the number of text files in the concatenated text file.
        '''
        return len(self._index)

    def __enter__(self):
        '''Return the TextIndex object.
        '''
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        '''Close the text file when the object is exited.
        '''
        if self._text_file is not None:
            self._text_file.close()
            self._text_file = None

    def __del__(self):
        '''Close the text file when the object is deleted.
        '''
        if self._text_file is not None:
            self._text_file.close()
            self._text_file = None

    def _read_index(self):
        '''Read the index file and return a dictionary with the text file names
        as keys and the number of characters in each text file as values.
        '''
        index = {}
        prev_nr_char = 0
        with open(self._idx_file_name, 'r') as idx_file:
            for line in idx_file:
                name, nr_char_str = line.split('\t')
                index[name] = FileIndex(prev_nr_char, int(nr_char_str), )
                prev_nr_char += index[name][1]
        return index

    def _read_text(self, query, nr_bytes_to_read=None):
        '''Read the text file by specifying the name of the text file, or by the
        sequential index in the concatenated text file.  Additionally, the user
        can specify the number of characters to read from the text file.
        '''
        if isinstance(query, str):
            offset, nr_bytes = self._index[query]
        elif isinstance(query, int):
            offset, nr_bytes = list(self._index.values())[query]
        else:
            raise TypeError('Query must be a string or an integer')
        if nr_bytes_to_read is None:
            nr_bytes_to_read = nr_bytes
        elif nr_bytes_to_read > nr_bytes:
            raise ValueError('nr_bytes_to_read must be less than or equal to the number of bytes in the text file')
        elif nr_char < 0:
            raise ValueError('nr_char must be positive')
        self._text_file.seek(offset)
        text = self._text_file.read(nr_bytes_to_read)
        return text.decode('utf-8')
