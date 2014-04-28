require 'spec_helper'
require 'pavlov_rss'
require 'nokogiri'

describe PavlovRss::Reader do
  describe '#hash_to_item' do
    subject { described_class.new.hash_to_item(hash) }

    context do
      let(:hash) do
        {'rss' => {'channel' => {'item' => []}}}
      end
      it { should be_empty }
    end

    context do
      let(:hash) do
        {'rss' => {'channel' => {'item' =>
          {'title' => 'title1'}
        }}}
      end
      it { should have(1).item }
    end

    context do
      let(:hash) do
        {'rss' => {'channel' => {'item' => [
          {'title' => 'title1'},
          {'title' => 'title2'},
        ]}}}
      end
      it { should have(2).items }
    end

    context 'with atom' do
      let(:hash) do
        {'feed' => {'entry' => [
          {'title' => 'title1'},
          {'title' => 'title2'},
        ]}}
      end
      it { should have(2).items }
    end
  end

  describe '#rss_to_hash' do
    shared_examples 'hashfied rss', rss_to_hash: :works  do
      subject { described_class.new.rss_to_hash(Nokogiri.XML(rss)) }
      it { should == expected }
    end

    describe 'works on general rss', rss_to_hash: :works do
      let(:rss) { feed('rss2.xml') }
      let(:expected) do
        {'rss'=>{'version'=>'2.0', 'channel'=>{'title'=>'title', 'link'=>'http://example.com', 'description'=>'description', 'item'=>[{'title'=>'title2', 'link'=>'http://example.com/title2', 'description'=>'description2'}, {'title'=>'title1', 'link'=>'http://example.com/title1', 'description'=>'description1'}]}}}
      end
    end

    describe 'works on 1-item rss', rss_to_hash: :works do
      let(:rss) { feed('rss1.xml') }
      let(:expected) do
        {'rss' => {'version'=>'2.0', 'channel'=>{'title'=>'title', 'link'=>'http://example.com', 'description'=>'description', 'item'=>{'title'=>'title1', 'link'=>'http://example.com/title1', 'description'=>'description1'}}}}
      end
    end

    describe 'works on 0-item rss', rss_to_hash: :works do
      let(:rss) { feed('rss0.xml') }
      let(:expected) do
        {'rss' => {'version'=>'2.0', 'channel'=>{'title'=>'title', 'link'=>'http://example.com', 'description'=>'description'}}}
      end
    end

    describe 'works on atom', rss_to_hash: :works do
      let(:rss) { feed('atom.xml') }
      let(:expected) do
        {'feed'=>{'xmlns'=>'http://www.w3.org/2005/Atom', 'entry'=>{'title'=>'title', 'id'=>'tag_string', 'content'=>'content'}}}
      end
    end
  end

  describe '#fetch' do
    shared_examples 'fetched rss', fetch: :works do
      before { subject.opener { rss } }
      its(:fetch) { should == expected }
    end

    describe 'works with rss0.xml', fetch: :works do
      let(:rss) { feed('rss0.xml') }
      let(:expected) { [] }
    end

    describe 'works with rss1.xml', fetch: :works do
      let(:rss) { feed('rss1.xml') }
      let(:expected) do
        [
          {"title"=>"title1", "link"=>"http://example.com/title1", "description"=>"description1"},
        ]
      end
    end

    describe 'works with rss2.xml', fetch: :works do
      let(:rss) { feed('rss2.xml') }
      let(:expected) do
        [
          {"title"=>"title2", "link"=>"http://example.com/title2", "description"=>"description2"},
          {"title"=>"title1", "link"=>"http://example.com/title1", "description"=>"description1"},
        ]
      end
    end

    describe 'works with rss3.xml', fetch: :works do
      let(:rss) { feed('rss3.xml') }
      let(:expected) do
        [
          {"title"=>"title3", "link"=>"http://example.com/title3", "description"=>"description3"},
          {"title"=>"title2", "link"=>"http://example.com/title2", "description"=>"description2"},
          {"title"=>"title1", "link"=>"http://example.com/title1", "description"=>"description1"},
        ]
      end
    end

    describe 'works with rss4.xml', fetch: :works do
      let(:rss) { feed('rss4.xml') }
      let(:expected) do
        [
          {"title"=>"title4", "link"=>"http://example.com/title4", "description"=>"description4"},
          {"title"=>"title3", "link"=>"http://example.com/title3", "description"=>"description3"},
          {"title"=>"title2", "link"=>"http://example.com/title2", "description"=>"description2"},
        ]
      end
    end

    describe 'works with rss5.xml', fetch: :works do
      let(:rss) { feed('rss5.xml') }
      let(:expected) do
        [
          {"title"=>"title5", "link"=>"http://example.com/title5", "description"=>"description5"},
          {"title"=>"title4", "link"=>"http://example.com/title4", "description"=>"description4"},
          {"title"=>"title3", "link"=>"http://example.com/title3", "description"=>"description3"},
        ]
      end
    end
  end

  describe '#check' do
    shared_examples 'check works', check: :works do
      before do
        subject.stub(:fetch).and_return(*fetches)
        subject.check.should be_empty
      end
      its(:check) { should == expected }
    end

    describe 'works with empty items', check: :works do
      let(:fetches) { [[], []] }
      let(:expected) { [] }
    end

    describe 'works with same items', check: :works do
      let(:fetches) do
        [
          [{'title' => '1'}],
          [{'title' => '1'}],
        ]
      end
      let(:expected) { [] }
    end

    describe 'works with added items', check: :works do
      let(:fetches) do
        [
          [],
          [{'title' => '1'}],
        ]
      end
      let(:expected) { [{'title' => '1'}] }
    end

    describe 'works with removed items', check: :works do
      let(:fetches) do
        [
          [{'title' => '1'}],
          [],
        ]
      end
      let(:expected) { [] }
    end

    describe 'works with various items', check: :works do
      let(:fetches) do
        [
          [
            {'title' => 'static1'},
            {'title' => 'static2'},
            {'title' => 'remove1'},
            {'title' => 'remove2'},
          ],
          [
            {'title' => 'static1'},
            {'title' => 'static2'},
            {'title' => 'add1'},
            {'title' => 'add2'},
          ],
        ]
      end
      let(:expected) do
        [
          {'title' => 'add1'},
          {'title' => 'add2'},
        ]
      end
    end

    it 'works with an filter' do
      fetches = [
        [],
        [
          {'title' => '1-1'},
          {'title' => '2'},
          {'title' => '1-2'},
        ],
      ]
      expected = [
        {'title' => '1-1'},
        {'title' => '1-2'},
      ]
      subject.stub(:fetch).and_return(*fetches)
      subject.check.should be_empty
      subject.check do |item|
        item['title'] =~ /^1/
      end.should == expected
    end

    it 'works with nil filter' do
      fetches = [
        [],
        [
          {'title' => '1-1'},
          {'title' => '2'},
          {'title' => '1-2'},
        ],
      ]
      expected = [
        {'title' => '1-1'},
        {'title' => '2'},
        {'title' => '1-2'},
      ]
      subject.stub(:fetch).and_return(*fetches)
      subject.check.should be_empty
      subject.check(&nil).should == expected
    end
  end
end
