# -*- coding: utf-8 -*-

require "time"

Plugin.create(:mikutter_cvse) do
  command(
          :mikutter_cvse,
          name: 'ワクチンの副反応を報告する',
          condition: lambda{ |opt| true },
          visible: true,
          role: :timeline
          ) do |opt|
    opt.messages.each do |message|
      Plugin.call(:camouflage_vaccine_side_effects, message)
    end
  end

  on_camouflage_vaccine_side_effects do | |
    temperature = rand(34.0...40.0).round(1).to_s
    vaccine = ['フ○イザー', 'モデ○ナ', '○ストラ○ネカ', 'ス○ートニクV'].sample
    arm = ['ワクチンを打った方の腕', 'ワクチンを打ってない方の腕', '右腕', '左腕', 'ケツ'].sample
    arm_effects = ['痛い。', 'かゆい。', '全く上がらない。', '少し上がるようになってきた。', 'もげた。'].sample
    side_effect_options = [
      '妙にお腹が空く。',
      '報告したい欲を抑えきれない。',
      'Bluetoothが使えるようになってきた。',
      '無線LANが使えるようになってきた。',
      '5G通信ができるようになってきた。',
      '体に水道マグネットが張り付く。',
      '猫が近寄ってきた。',
      '真理に近づいてきた。',
      '気のせいだったかも。',
      'ここからかな？',
      'だいぶマシになってきた。',
      'めっちゃダルい。',
      '衝動買いをした。これも副反応だろう。',
    ]

    if defined? UserConfig[:vaccine_date_first] and defined? UserConfig[:vaccine_date_second] and UserConfig[:vaccine_date_first] != '' and UserConfig[:vaccine_date_second] != ''
      now = Time.now
      first = Time.parse(UserConfig[:vaccine_date_first] + ':00:00')
      second = Time.parse(UserConfig[:vaccine_date_second] + ':00:00')

      if now < first
        vaccine_date = first
        diff = first - now
      elsif second < now
        vaccine_date = second
        diff = now - second
      elsif first < now
        # 中間あたりで1回目と2回目を切り替え
        if now < first + (second - first) / 2
          vaccine_date = first
          diff = now - first
        else
          vaccine_date = second
          diff = second - now 
        end
      end
      
      vaccine_times = vaccine_date == first ? 1 : 2
      report_days = (diff / 86400).floor
      report_days_str = 0 < report_days ? report_days.to_s + '日と' : ''
      report_time = diff < 86400 ? (diff / 3600).round.to_s : (diff % 86400 / 3600).round.to_s
      is_ago = now < vaccine_date ? '前' : '後'

      vaccine_report_time = 'ワクチン' + vaccine_times.to_s + '回目接種から' \
                          + report_days_str + report_time + '時間' + is_ago + '。'
    else
      # 設定がないときはランダムモード
      # 最初からこれで良かっただろそれはそう
      days = rand(1...100).to_s
      time = rand(1...100).to_s
      timing = (rand(100) % 2) == 0 ? '前' : '後'
      vaccine_report_time = 'ワクチン接種' + days + '日と' +  time + '時間' + timing + '。'
    end

    msg = vaccine + vaccine_report_time \
          + '体温は' + temperature + "℃。\n" + arm + "が" + arm_effects \
          + side_effect_options.sample + side_effect_options.sample
    world, = Plugin.filtering(:world_current, nil)
    compose(world, body: msg)
  end

  settings "ワクチンの副反応を報告する" do
    label("ワクチン接種日")
    input("1回目の日時",:vaccine_date_first)
    input("2回目の日時",:vaccine_date_second)
    label("※「YYYY-MM-DD HH」の形式で入力してください")
    label("省略すると、ランダムモードになります")
  end
end