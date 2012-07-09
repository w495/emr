% Copyright (c) 2011-2012, Tom Van Cutsem, Vrije Universiteit Brussel
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%    * Redistributions of source code must retain the above copyright
%      notice, this list of conditions and the following disclaimer.
%    * Redistributions in binary form must reproduce the above copyright
%      notice, this list of conditions and the following disclaimer in the
%      documentation and/or other materials provided with the distribution.
%    * Neither the name of the Vrije Universiteit Brussel nor the
%      names of its contributors may be used to endorse or promote products
%      derived from this software without specific prior written permission.
%
%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
%ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
%WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%DISCLAIMED. IN NO EVENT SHALL VRIJE UNIVERSITEIT BRUSSEL BE LIABLE FOR ANY
%DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
%(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES
%LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
%ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
%(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
%SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

% Grep (text search) example using the basic parallel MapReduce
% implementation:
-module(test_grep).
-export([grep/2]).
-import(emr, [mapreduce/3]).

%% Grep
grep(DirName, Word) ->
  NumberedFiles = demo_inverted_index:list_numbered_files(DirName),
  Index = mapreduce(NumberedFiles,
                    make_filter_mapper(Word), fun remove_duplicates/3),
  dict:find(Word, Index).

% this function is used as a Map function
make_filter_mapper(MatchWord) ->
  fun (_Index, FileName, Emit) ->
    {ok, [Words]} = file:consult(FileName),
    lists:foreach(fun (Word) ->
      case MatchWord == Word of
        true -> Emit(Word, FileName);
        false -> false
      end
    end, Words)
  end.
  
% this function is used as a Reduce function
remove_duplicates(Word, FileNames, Emit) ->
  UniqueFiles = sets:to_list(sets:from_list(FileNames)),
  lists:foreach(fun (FileName) -> Emit(Word, FileName) end, UniqueFiles).