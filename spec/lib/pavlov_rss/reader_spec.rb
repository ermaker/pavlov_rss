require 'spec_helper'
require 'pavlov_rss'
require 'nokogiri'
require 'fake_web'

describe PavlovRss::Reader do
  after do
    FakeWeb.clean_registry
  end

  describe '#hash_to_item' do
    subject { described_class.new.hash_to_item(hash) }

    describe do
      let(:hash) do
        {'rss' => {'channel' => {'item' => []}}}
      end
      it { should be_empty }
    end

    describe do
      let(:hash) do
        {'rss' => {'channel' => {'item' =>
          {'title' => 'title1'}
        }}}
      end
      it { should have(1).item }
    end

    describe do
      let(:hash) do
        {'rss' => {'channel' => {'item' => [
          {'title' => 'title1'},
          {'title' => 'title2'},
        ]}}}
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

  describe '#new_items' do
    it 'returns empty with same rss' do
      rss1 = Nokogiri.XML(feed('rss1.xml'))
      rss2 = Nokogiri.XML(feed('rss1.xml'))
      items = subject.new_items rss1, rss2
      items.should == []
    end

    it 'returns empty with not same rss' do
      rss1 = Nokogiri.XML(feed('rss1.xml'))
      rss2 = Nokogiri.XML(feed('rss2.xml'))
      items = subject.new_items rss1, rss2

      items.should == [
        {
        'title'=>'title2',
        'link'=>'http://example.com/title2',
        'description'=>'description2'
      }]
    end
  end

  shared_context 'with an example reader', :with_example_reader do
    let(:uri) { 'http://example.com/rss.xml' }
    subject { described_class.new uri }
  end

  shared_context 'with static rss', :with_static_rss do
    before do
      FakeWeb.register_uri(:get, uri, body: feed('rss1.xml'))
    end
  end

  describe '#check', :with_example_reader, :with_static_rss do
    it 'returns [] at first time' do
      subject.check.should == []
    end

    it 'returns [] without changes' do
      subject.check.should == []
      subject.check.should == []
    end
  end

  describe '#check', :with_example_reader do
    it 'does not return [] with any chagnes' do
      FakeWeb.register_uri(
        :get, uri, [
          {body: feed('rss1.xml')},
          {body: feed('rss2.xml')},
      ])
      subject.check
      subject.check.should_not == []
    end
  end

  describe '#check' do
    let(:uri) { 'http://example.com/rss.xml' }
    before do
      FakeWeb.register_uri(
        :get, uri, [
          {body: feed('rss0.xml')},
          {body: feed('rss1.xml')},
          {body: feed('rss2.xml')},
          {body: feed('rss3.xml')},
          {body: feed('rss4.xml')},
          {body: feed('rss5.xml')},
      ])
    end

    shared_examples '#check works', check: :works do
      specify do
        subject.check.should be_empty
        subject.check.should == [
          {
          'title'=>'title1',
          'link'=>'http://example.com/title1',
          'description'=>'description1'
        }]
        subject.check.should == [
          {
          'title'=>'title2',
          'link'=>'http://example.com/title2',
          'description'=>'description2'
        }]
        subject.check.should == [
          {
          'title'=>'title3',
          'link'=>'http://example.com/title3',
          'description'=>'description3'
        }]
        subject.check.should == [
          {
          'title'=>'title4',
          'link'=>'http://example.com/title4',
          'description'=>'description4'
        }]
        subject.check.should == [
          {
          'title'=>'title5',
          'link'=>'http://example.com/title5',
          'description'=>'description5'
        }]
        subject.check.should == []
      end
    end

    describe 'works with a labmda', check: :works do
      before do
        subject.opener { open(uri, &:read) }
      end
    end

    describe 'works with a labmda', check: :works do
      subject { described_class.new uri }
    end
  end
end
