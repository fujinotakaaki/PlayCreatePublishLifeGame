module ApplicationHelper
  # カテゴリ一覧の表示判定メソッド(layouts/application.html.erb)
  def include_category_index?( _controller_name, _action_name )
    # カテゴリ一覧を表示する条件
    white_list = [
      %w( members show ),
      %w( patterns index )
    ]
    # 判定結果
    white_list.include?( [ _controller_name, _action_name] )
  end

  # 日付を見やすい書式に変換するメソッド(patterns/property)
  def date_format( create_time )
    # TimeWithZone => DateTimeに変換
    t = create_time.to_datetime
    # 書式に当てはめる（例）2020年03月19日 03:15
    t.strftime('%Y年%m月%d日 %H:%M')
  end

  # deviseコントローラー関連のページか判定
  def is_devise_controller?( _controller_name )
    # deviseコントローラー関連のコントローラー名一覧
    black_list = %w( confirmations omniauth_callbacks passwords registrations sessions unlocks )
    black_list.include?( _controller_name )
  end

  # link_to_if代替メソッド => falseのときにはネストしている中身を出力
  def link_to_if_with_block(condition, options = nil, html_options = nil, &block)
    if condition
      link_to(options, html_options, &block)
    else
      capture(&block)
    end
  end
end
