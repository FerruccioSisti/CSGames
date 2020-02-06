class Solution {
    boolean[][] visited;
    int iRow, iCol;
    public boolean exist(char[][] board, String word)
    {
        //initialize row and col variables with length of row and length of column
        iRow = board.length-1;
        iCol = board[0].length-1;
        //create a boolean array the same size as the board to know if we visited or not
        visited = new boolean[iRow+1][iCol+1];

        //need to loop through all rows and columns until we find a matches for the first letter in the word we are searching for
        for(int i=0; i<=iRow; i++)
        {
            for(int j=0; j<=iCol; j++)
            {
                //check if the current board element matches the first letter of the word and also call our DFS method to continue searching for the rest of the word
                if(board[i][j] == word.charAt(0) && magic(i, j, 0, word, board))
                {
                    return true;
                }
            }
        }
        return false;
    }

    public boolean magic(int i, int j, int index, String word, char[][] board)
    {
        //if the current index is the end of the word
        if (index == word.length())
        {
            return true;
        }

        //if curr row/col is out of bounds or if board element is not the next letter we are searching for, or if we have already visited this element
        if ((i < 0) || (i > iRow) || (j < 0) || (j > iCol) || board[i][j] != word.charAt(index) || visited[i][j])
        {
            return false;
        }

        //we can now set this element to true because we havent visited it yet and it's the letter we are searching for next
        visited[i][j] = true;

        //recursive call to surrounding elements (don't worry about diagonals)
        if( magic(i-1, j, index+1, word, board) || magic(i+1, j, index+1, word, board) ||
            magic(i, j-1, index+1, word, board) || magic(i, j+1, index+1, word, board) )
        {
            return true;
        }
        //if the next letter of the word is not surrounding our current letter, then we can't use this letter so set its visited value to false and try again from a different start point
        visited[i][j] = false;
        return false;
    }
}
