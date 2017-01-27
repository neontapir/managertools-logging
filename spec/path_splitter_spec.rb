require "./lib/path_splitter.rb"

describe PathSplitter do
  let(:splitter_instance) { (Class.new { include PathSplitter }).new }

  context "splitting a path" do
    it "should handle a path string" do
      expect(splitter_instance.split_path("a/b/c")).to eq(["a","b","c"])
    end
  end
end
