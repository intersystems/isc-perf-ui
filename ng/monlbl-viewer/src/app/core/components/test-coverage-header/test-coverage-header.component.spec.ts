import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TestCoverageHeaderComponent } from './test-coverage-header.component';

describe('TestCoverageHeaderComponent', () => {
  let component: TestCoverageHeaderComponent;
  let fixture: ComponentFixture<TestCoverageHeaderComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [TestCoverageHeaderComponent]
    });
    fixture = TestBed.createComponent(TestCoverageHeaderComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
