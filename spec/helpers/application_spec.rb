# データ変換のテスト
# '010\n001\n111' => making_params =>'010\n001\n111'
# making_params = {
#   :margin_top=>0,
#   :margin_bottom=>0,
#   :margin_left=>0,
#   :margin_right=>0,
#   :normalized_rows_sequence=>"2,1,7"
# }

# require 'rails_helper'
# RSpec.describe "MakingHelper", type: :helper do
#   context ':making_random valid test'
#   100.times do
#     it "success conversion" do
#       test = attributes_for :making_random, :text
#       making_params = helper.build_up_pattern_params_from test[:making_text]
#       expect(Hash).to be === making_params
#       expect(String).to be === making_params[:normalized_rows_sequence]
#       calce = making_params[:normalized_rows_sequence].split(?,).size + making_params[:margin_top] + making_params[:margin_bottom]
#       calcr = test[:making_text].split(?,).size
#       # unless calce==calcr then
#       #   pp making_params, calce
#       #   pp test, calcr
#       # end
#       expect(calce).to eq calcr
#       test3 = helper.build_up_bit_strings_from Pattern.new(making_params)
#       expect(test3).to eq test[:making_text].split(?,)
#     end
#   end
# end
