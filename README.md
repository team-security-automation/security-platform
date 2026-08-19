# security-platform

## 관련 레포지토리
- Dashboard(웹 대시보드): (레포 링크 추가 예정)

## 참고 자료
- 취약점 기준표(각 서버에 주입된 U-01~67, WEB-01~26 취약/양호 목록): 노션에서 관리 (링크는 나중에 추가)
- JSON 스키마, DB 스키마: 노션에서 관리 (링크는 나중에 추가)

## 폴더 구조
```
scripts/
  common/           - 공통 함수(JSON 출력 등)
  rocky/            - Rocky Linux 9, 10 공용 진단·조치 스크립트
    account/        - 계정관리 (U-01~U-13)
    file/           - 파일 및 디렉터리 관리 (U-14~U-33)
    service/        - 서비스 관리 (U-34~U-63)
    patch/          - 패치 관리 (U-64)
    log/            - 로그 관리 (U-65~U-67)
  ubuntu/           - Ubuntu 24, 26 공용 진단·조치 스크립트 (rocky와 동일 하위구조)
  web/              - 웹서비스 점검 (WEB-01~WEB-26, rockyweb 전용)
ansible/            - 인벤토리, 플레이북, 역할 (오케스트레이션)
```