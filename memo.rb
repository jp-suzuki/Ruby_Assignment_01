require "csv" # CSVファイルを扱うためのライブラリを読み込んでいます

file_name = "default"
EXTENSION_CSV = ".csv"

files_list = []
selected_file = 0
selected_row = 0
row_count = 0


def output_table(headerA, headerB, targetTable)
  puts "----------------"
  puts " #{headerA} | #{headerB}"
  puts "----+-----------"
  for output_row in 1..targetTable.count do
    puts "#{output_row.to_s.rjust(3)} | #{targetTable[output_row - 1]}"
  end
  puts "----------------"
end

loop do
  puts "1 → 新規でメモを作成する / 2 → 既存のメモを編集する"
  print "> "
  memo_type = gets.chomp
  ### メモ ###
  # printメソッドは改行を行わない。
  # 課題のサンプル部分ではto_iを使用していたが、1.1などの小数を切り捨てて取得してしまうため除外。
  # このとき、memo_type = gets と記述すると、末尾に改行文字 \n が入ってしまう。
  # これを回避するには、chompメソッドを用いて、改行を無視して読み込む。

  if memo_type == "1" || memo_type == "１"
    begin #評価対象はFile.new(file_name, "w")のみ 
      puts "新規作成するメモの名前を入力してください。"
      print "> "
      file_name = gets.chomp.concat EXTENSION_CSV
      if File.exist?(file_name)
        ### メモ ###
        # File.exist?は、指定した名前のファイルが存在するかを判定し、存在する場合はtrueを、しない場合はfalseを返す
        # ディレクトリが存在するかを確認したい場合は、Dir.exist?を使用する
  
        puts "#{file_name}は既に存在します。上書きしますか？"
        puts "1 → 上書きして新規作成する / それ以外 → キャンセル"
        print "> "
        overwrite = gets.chomp
        if overwrite != "1" && overwrite != "１"
          puts "メモの作成をキャンセルしました。"
          puts "初めからやり直してください。"
          next
        end
      end
      File.new(file_name, "w")

    rescue
      puts "ファイル名に使用できない文字[ / ]が含まれています。"
      retry
    end

    puts "次の名前でcsvファイルを作成しました : #{file_name}"
    puts "メモしたい内容を入力してください。"
    puts "完了したらCtrlキーとDキーを同時に押してください。"
    selected_file = File.open(file_name, "w")
    input_strings = readlines
    selected_file.puts(input_strings)
    puts "保存しました。"
    break # メモ編集方法選択のループから抜ける

  elsif memo_type == "2" || memo_type == "２"
    Dir.glob("*.csv") do |item|
      files_list.push(item)
    end
    if files_list.count == 0
      puts "編集可能なメモが存在しません。"
      puts "1を選択し、メモを新規作成してください"
    else
      puts "編集可能なメモの一覧を表示します。"
      output_table("ID", "名前", files_list)
      loop do
        puts "編集するファイルのIDを入力してください。"
        print "> "
        selected_file = gets.to_i
        if selected_file < 1 || files_list.count < selected_file
          puts "入力されたIDは存在しません。"
          next # ファイルIDの入力まで戻る
        else
          csv_table = []
          CSV.foreach(files_list[selected_file - 1]) do |row|
            csv_table.push(row.to_csv.chomp)
          end
          puts "#{files_list[selected_file - 1]} を表示します" # ファイルID（１スタート）と配列（０スタート）の調整
          output_table("行", "内容", csv_table)

          memo_edit = loop do
            puts "編集モードを選んでください。"
            puts "1 → 行番号を指定して編集 / 2 → ファイルの末尾へ追記 / 3 → 行番号を指定して削除"
            print "> "
            edit_mode = Integer(gets, exception: false)
            ### メモ ###
            # Integer()メソッドは引数の整数への変換を試みる。
            # 引数が整数の形式であればその整数を返すが、文字列や小数の場合はArgumentErrorが発生する。
            # exception: falseオプションを使用することで、エラーのかわりに nil を返すようになる。
            # nil は他の言語における null と同様、値が存在しないことを示す特別なオブジェクト。
            # 変数の中身が nil であるかは、 .nil? メソッドで厳密に判定できる。
            
            case edit_mode
            when 1 # 行番号を指定して編集
              puts "編集する行番号を入力してください。"
              print "> "
              selected_row = Integer(gets, exception: false)
              if selected_row.nil?
                puts "行番号は整数で入力してください。"
                next # 行番号の入力まで戻る
              elsif selected_row < 1 || csv_table.count < selected_row
                puts "入力された行番号は存在しません。"
                next # 行番号の入力まで戻る
              else
                puts "メモの内容を入力してください"
                print "> "
                csv_table[selected_row - 1] = gets.chomp
              end
            when 2 # ファイルの末尾へ追記
              puts "追記したい内容を入力してください。"
              puts "完了したらCtrlキーとDキーを同時に押してください。"
              add_strings = readlines.map(&:chomp)
              csv_table.concat(add_strings)
            when 3 # 行番号を指定して削除
              puts "削除する行番号を入力してください。"
              print "> "
              selected_row = Integer(gets, exception: false)
              if selected_row.nil?
                puts "行番号は整数で入力してください。"
                next # 行番号の入力まで戻る
              elsif selected_row < 1 || csv_table.count < selected_row
                puts "入力された行番号は存在しません。"
                next # 行番号の入力まで戻る
              else
                puts "#{selected_row}行目を削除しました。"
                csv_table.delete_at(selected_row - 1)
              end
            when nil
              puts "整数で入力してください。"
              next # 編集モードの指定まで戻る
            else
              puts "1から3までの整数で入力してください。"
              next # 編集モードの指定まで戻る
            end
            
            output_table("行", "内容", csv_table)

            loop do
              puts "メモの編集を続けますか？"
              puts "1 → 続けて編集する / 2 → 変更内容を保存し、編集を終了する / 3 → 変更内容を破棄し、編集を終了する"
              print "> "

              case Integer(gets, exception: false)
              when 1
                break # 行番号の入力まで戻る
              when 2
                CSV.open(files_list[selected_file - 1], "w") do |csv|
                  csv_table.each do |overwrite_text|
                    csv << [overwrite_text]
                  end
                end
                puts "変更内容を保存しました。"
                break :memo_edit # 行番号指定のループから抜ける
              when 3
                puts "変更内容を破棄しました。"
                break :memo_edit # 行番号指定のループから抜ける
              else
                puts "1から3までの整数で入力してください。"
                next
              end
            end
          end
          break # ファイルID指定のループから抜ける
        end
      end
    end
    break # メモ編集方法選択のループから抜ける
  else
    puts "1か2を入力してください。"
  end
end