require "rails_helper"

RSpec.describe Section do
  context 'when a section is updated' do
    context 'when period information is updated' do
      before do
        @section = create(:section, num_periods: 5, 
          periods_day: [3, 5, 2, 2, 4], 
          periods_start: [1200, 800, 1600, 800, 800], 
          periods_end: [1400, 900, 1800, 900, 1000], 
          periods_type: ['LAB', 'LEC', 'TEST', 'LEC', 'LEC'])
      end

      it 'sorts periods by day, and then start time' do 
        expect(@section.num_periods).to eq 5
        expect(@section.periods_day).to eq [2, 2, 3, 4, 5]
        expect(@section.periods_start).to eq [800, 1600, 1200, 800, 800]
        expect(@section.periods_end).to eq [900, 1800, 1400, 1000, 900]
        expect(@section.periods_type).to eq ['LEC', 'TEST', 'LAB', 'LEC', 'LEC']
      end
    end

    context 'when non-period information is updated' do
      before do
        Section.skip_callback(:save, :before, :sort_periods, if: :periods_changed?)
        @section = create(:section, num_periods: 5, 
          periods_day: [3, 5, 2, 2, 4], 
          periods_start: [1200, 800, 1600, 800, 800], 
          periods_end: [1400, 900, 1800, 900, 1000], 
          periods_type: ['LAB', 'LEC', 'TEST', 'LEC', 'LEC'])
        Section.set_callback(:save, :before, :sort_periods, if: :periods_changed?)
        @section.update(instructors: ['>:-]', ':-)', ':-|', ':-(', '>:-['])
      end

      it 'does not sort period' do 
        expect(@section.num_periods).to eq 5
        expect(@section.periods_day).to eq [3, 5, 2, 2, 4]
        expect(@section.periods_start).to eq [1200, 800, 1600, 800, 800]
        expect(@section.periods_end).to eq [1400, 900, 1800, 900, 1000]
        expect(@section.periods_type).to eq ['LAB', 'LEC', 'TEST', 'LEC', 'LEC']
      end
    end
  end

  context 'when sections are created and destroyed' do
    before do
      allow(EventSender).to receive(:send_event)
      @section = create(:section)
      @section.destroy
    end

    it 'sends a section_added event' do
      expect(EventSender).to have_received(:send_event).with(anything, "section_added", any_args)
    end

    it 'sends a section_removed event' do
      expect(EventSender).to have_received(:send_event).with(anything, "section_removed", any_args)
    end
  end

  context 'when section seats are added' do
    before do
      allow(EventSender).to receive(:send_event)
    end

    context 'and section opens' do
      before do
        @section = create(:section, seats: 150, seats_taken: 160)
        @section.update(seats: 165)
      end

      it 'sends a seats_added_section_opened event' do
        expect(EventSender).to have_received(:send_event).with(anything, "seats_added_section_opened", any_args)
      end
    end

    context 'and section remains closed' do
      before do
        @section = create(:section, seats: 50, seats_taken: 30)
        @section.update(seats: 60)
      end

      it 'sends a seats_added event' do
        expect(EventSender).to have_received(:send_event).with(anything, "seats_added", any_args)
      end
    end
  end

  context 'when section seats are removed' do
    before do
      allow(EventSender).to receive(:send_event)
    end

    context 'and section closes' do
      before do
        @section = create(:section, seats: 250, seats_taken: 240)
        @section.update(seats: 200)
      end

      it 'sends a seats_removed_section_closed event' do
        expect(EventSender).to have_received(:send_event).with(anything, "seats_removed_section_closed", any_args)
      end
    end

    context 'and section remains opened' do
      before do
        @section = create(:section, seats: 100, seats_taken: 70)
        @section.update(seats: 90)
      end

      it 'sends a seats_removed event' do
        expect(EventSender).to have_received(:send_event).with(anything, "seats_removed", any_args)
      end
    end
  end

  context 'when section is opened' do
    before do
      allow(EventSender).to receive(:send_event)
      @section = create(:section, seats: 100, seats_taken: 100)
      @section.update(seats_taken: 99)
    end

    it 'sends a sectionopened event' do
      expect(EventSender).to have_received(:send_event).with(anything, "sectionopened", any_args)
    end
  end

  context 'when section is closed' do
    before do
      allow(EventSender).to receive(:send_event)
      @section = create(:section, seats: 200, seats_taken: 199)
      @section.update(seats_taken: 200)
    end

    it 'sends a secionclosed event' do
      expect(EventSender).to have_received(:send_event).with(anything, "sectionclosed", any_args)
    end
  end
end